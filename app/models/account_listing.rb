class AccountListing < ActiveRecord::Base
  belongs_to :account
  belongs_to :listing, :inverse_of => :account_listings
  has_many :order_items, :dependent => :restrict_with_exception

  PRICING_TYPES = %w{fixed formula market_lowest market_highest follow_amazon}
  CUSTOM_PRICING_TYPES = PRICING_TYPES - %w{fixed follow_amazon}
  TYPES = %w{buy_now auction}
  FAILED_STATUSES = %w{create_failed update_failed delete_failed}
  PENDING_STATUSES = %w{pending_create pending_update pending_delete}
  PUBLISHED_STATUSES = %w{active pending_update update_failed delete_failed}
  STATUSES = %w{active inactive processing} + PENDING_STATUSES + FAILED_STATUSES

  validates_presence_of :account, :listing
  validates_inclusion_of :pricing_type, :in => PRICING_TYPES, :allow_blank => true
  validates_inclusion_of :status, :in => STATUSES, :allow_blank => false
  validates_inclusion_of :listing_type, :in => TYPES, :allow_blank => true

  scope :pending, -> { where(:status => PENDING_STATUSES) }
  scope :published, -> { where(:status => PUBLISHED_STATUSES) }
  scope :publishable, -> { where(:status => PUBLISHED_STATUSES + %w{pending_create}) }
  scope :with_custom_pricing, -> { where(:pricing_type => CUSTOM_PRICING_TYPES) }

  serialize :integration_state
  serialize :messages

  after_save :check_trigger_operations
  after_save :enqueue_rescan_pricing
  after_save :update_discount_price!
  before_destroy {
    raise "Cannot delete account listing" if published?
  }
  before_validation :infer_defaults

  def price?
    !price.blank?
  end

  def discount?
    !discount_price.blank?
  end

  def price
    if pricing_type.try(:to_sym) == :follow_amazon && !self.account.marketplace.amazon?
      listing.account_listings.find { |l| l.account.marketplace.amazon? }.try(:price)
    else
      self[:price]
    end
  end

  def messages
    { :errors => [], :warnings => [], :internal_errors => [], :internal_warnings => [] }.merge(self[:messages] || {})
  end

  def published?
    PUBLISHED_STATUSES.include?(status.to_s)
  end
  alias active? published?

  def publishable?
    (PUBLISHED_STATUSES + %w{pending_create}).include?(status.to_s)
  end

  def time_to_publish?
    listing.publish_on.blank? || listing.publish_on.past?
  end

  def unpublish!
    unless !published? || processing? || pending?
      status!(:pending_delete)
      ListingProcessor.enqueue([self])
    end
  end

  def publish!
    unless published? || processing? || pending?
      status!(:pending_create)
      AccountListing.delay_for(5.seconds).rescan_pricing_for(id, true) if needs_repricing?
      ListingProcessor.enqueue([self])
    end
  end

  def update!
    unless !published? || processing? || pending?
      status!(:pending_update)
      AccountListing.delay_for(5.seconds).rescan_pricing_for(id, true) if needs_repricing?
      ListingProcessor.enqueue([self])
    end
  end

  def processing?
    status.to_sym == :processing
  end

  def processing_error?
    FAILED_STATUSES.include?(status.to_s)
  end

  def editable?
    !(pending? || processing?)
  end

  def pending?(operation = nil)
    operation ? status.to_s == "pending_#{operation}" : PENDING_STATUSES.include?(status.to_s)
  end

  def cancel_pending!
    if pending?
      case status.to_sym
        when :pending_delete, :pending_update
          status!(:active) # this cancels pending delete and puts item back in active state
          update_column(:publish, true)
        when :pending_create
          status!(:inactive)
          update_column(:publish, false)
      end
    end
  end

  def inactive?
    status.to_sym == :inactive
  end

  def integration_state
    @integration_state ||= HashWithCallbacks.new(self[:integration_state] || {}, :changed => -> (changed_values) {
      self.update_attribute(:integration_state, @integration_state.to_h)
    })
  end

  def status!(status_code, errors = nil, warnings = nil, internal_errors = nil, internal_warnings = nil)
    update_columns(:status => status_code, :messages => { :errors => errors || [], :warnings => warnings || [], :internal_errors => internal_errors || [], :internal_warnings => internal_warnings || [] })
    # update publish value accordingly
    case status_code.to_sym
      when :active, :pending_create, :pending_update, :delete_failed, :update_failed
        update_column(:publish, true)
      when :inactive, :pending_delete, :create_failed
        update_column(:publish, false)
    end
  end

  def self.rescan_pricing_for(id, ignore_timestamps)
    account_listing = AccountListing.find(id)
    account_listing.rescan_pricing!(ignore_timestamps)
  end

  def rescan_pricing!(ignore_timestamp = false)
    return unless supports_repricing?
    return unless needs_repricing? || ignore_timestamp
    # set current price_updated_at to prevent multiple runs
    last_price_updated_at = price_updated_at
    update_columns(:price_updated_at => DateTime.now, :error_in_pricing_formula => nil)
    case pricing_type.to_sym
      when :formula
        calculator = Dentaku::Calculator.new
        begin
          new_price = calculator.evaluate!(self.formula, :Cost => self.listing.cost, :MinPrice => self.min_price, :ShippingPrice => self.listing.shipping_preset.price)
          new_price = [new_price, self.min_price || 0].max
        rescue Exception => ex
          if ex.is_a?(TypeError)
            update_column(:error_in_pricing_formula, "Invalid parameter value. Make sure you set referenced Cost or MinPrice values")
          else
            update_column(:error_in_pricing_formula, ex.message)
          end
        end
      when :market_lowest, :market_highest
        # TODO - implement
        new_price = price
        new_price = [new_price, self.min_price || 0].max
      else
        raise 'Invalid custom pricing type'
    end
    if new_price != price && !new_price.blank?
      update_attribute(:price, new_price)
      published? ? update! : publish!
      ListingProcessor.enqueue([self])
    end
    update_column(:price_updated_at, DateTime.now)
    return true
  rescue
    update_attribute(:price_updated_at, last_price_updated_at)
    return false
  end

  def supports_repricing?
    publishable? && custom_pricing?
  end

  def needs_repricing?
    supports_repricing? && (price_updated_at.blank? || price_updated_at < 2.hours.ago)
  end

  def custom_pricing?
    CUSTOM_PRICING_TYPES.include?(pricing_type)
  end

  def check_trigger_operations
    unless status_changed?
      if publish_changed?
        if publish?
          if self.status.to_sym == :pending_delete
            cancel_pending!
          else
            publish!
          end
        else
          unpublish!
        end
      elsif publish?
        update!
      end
    end
  end

  def update_discount_price!
    return unless publishable?

    event = account.sale_events.order('discount_percent DESC').find { |event|
      (event.start_date.blank? || event.start_date.past?) &&
          (event.end_date.blank? || event.end_date.future?) &&
          listing.item_category_id == event.item_category_id
    }
    new_price = [1.0 * price * (100 - event.discount_percent) / 100, min_price || 0].max if event

    unless discount_price == new_price
      update_column(:discount_price, new_price)
      update!
    end
  end

  private

  def infer_defaults
    (self.status = publish? ? :pending_create : :inactive) if self.status.blank?
  end

  def enqueue_rescan_pricing
    AccountListing.delay_for(5.seconds).rescan_pricing_for(self.id, false)
  end
end
