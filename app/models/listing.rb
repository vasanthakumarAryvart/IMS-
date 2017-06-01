class Listing < ActiveRecord::Base
  belongs_to :user
  belongs_to :item_category
  belongs_to :shipping_preset
  belongs_to :listing_template
  belongs_to :inventory_item
  has_many :warehouse_placements, :class_name => 'ListingWarehousePlacement', :inverse_of => :listing, :dependent => :destroy
  has_many :data_fields, :class_name => 'ListingDataField', :inverse_of => :listing, :dependent => :destroy
  has_many :account_listings, :inverse_of => :listing, :dependent => :destroy
  has_many :images, -> { order(:sort_order) }, :class_name => 'ListingImage', :inverse_of => :listing, :dependent => :destroy

  accepts_nested_attributes_for :warehouse_placements, :allow_destroy => true
  accepts_nested_attributes_for :data_fields
  accepts_nested_attributes_for :account_listings
  accepts_nested_attributes_for :images

  validates_presence_of :user, :item_category, :shipping_preset #, :title, :description, :cost
  validates_numericality_of :cost, :greater_than => 0, :allow_blank => true

  scope :for_user, -> (user) { where(:user_id => user.id) }
  scope :active, -> { where(:archived_at => nil) }
  scope :archived, -> { where('archived_at IS NOT NULL') }

  include CommonDataFields

  after_save :check_trigger_operations

  def can_delete?
    # only can delete a listing record when all account_listings are unpublished, editable and there are no ordersfor this listing
    editable? && !published? && account_listings.map(&:order_items).map(&:count).compact.inject(&:+) == 0
  end

  def unpublish!
    account_listings.published.each(&:unpublish!)
  end

  def published?
    account_listings.published.count > 0
  end

  def editable?
    account_listings.reject { |al| al.editable? }.empty?
  end

  def processing?
    account_listings.select { |al| al.processing? }.any?
  end

  def pending?
    !processing? && account_listings.select { |al| al.pending? }.any?
  end

  def processing_errors?
    account_listings.select { |al| al.processing_error? }.any?
  end

  def archived?
    !!archived_at
  end

  def archive!
    unpublish!
    update_attribute(:archived_at, DateTime.now)
  end

  def unarchive!
    update_attribute(:archived_at, nil)
  end

  def cancel_pending!
    account_listings.map(&:cancel_pending!)
  end

  def quantity
    warehouse_placements.map(&:quantity).compact.inject(&:+) || 0
  end

  def check_trigger_operations
    account_listings.reload.map(&:check_trigger_operations)
  end

  def account_listing_for_marketplace(marketplace)
    account_listings.joins(:account).where('accounts.marketplace_id' => marketplace.id).first
  end

  def warehouse_placements
    inventory_item ? inventory_item.warehouse_placements : super
  end
end
