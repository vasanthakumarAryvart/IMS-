class Account < ActiveRecord::Base
  belongs_to :user
  belongs_to :marketplace
  has_many :sale_events, -> { order(:start_date) }
  has_many :account_listings
  has_many :notifications
  has_many :orders
  has_many :buyers, :through => :orders

  validates_presence_of :user, :marketplace, :title

  serialize :state
  serialize :relisting_pricing

  accepts_nested_attributes_for :sale_events, :allow_destroy => true

  AUTO_RENEW_OPTIONS = %w{none daily weekly monthly}

  def state
    @state ||= HashWithCallbacks.new(self[:state] || {}, :changed => -> (changed_values) {
      self.update_attribute(:state, @state.to_h)
    })
  end

  def disconnect_integration!
    update_attribute(:state, nil)
  end

  def configured?
    !state.blank?
  end

  def integration
    @integration ||= Integrations.by_uid(marketplace.api_uid).new(state)
  end

  protected

  def update_integration_state!(s)
    self.update_attribute(:state, (s || @integration.state).to_h) if @integration
  end
end
