class InventoryItem < ActiveRecord::Base
  has_one :listing_template
  belongs_to :item_category
  belongs_to :item_source
  has_many :warehouse_placements, :class_name => 'InventoryWarehousePlacement', :inverse_of => :inventory_item, :dependent => :destroy
  has_many :listings

  serialize :details, Hash

  validates_presence_of :item_category
  validates_numericality_of :cached_profit_share_percent, :greater_than_or_equal_to => 0

  accepts_nested_attributes_for :warehouse_placements, :allow_destroy => true

  before_validation {
    self.cached_profit_share_percent = self.item_source.try(:profit_share_percent) || 0 if self.cached_profit_share_percent.blank?
  }

  STATUSES = ['recycled',
              'in transit',
              'triage',
              'recommerce',
              'sold',
              'returned to source']

  LOCATIONS = ['n/a',
               'triage',
               'to be listed',
               'refurbish']

  scope :active, -> { where('archived IS NULL OR archived = false') }

  def quantity
    warehouse_placements.map(&:quantity).compact.inject(&:+) || 0
  end

  def acquisition_cost
    self[:acquisition_cost] || 0.00
  end

  def archive!
    update_attribute(:archived, true)
  end

  def title
    [self.make, self.model].reject(&:blank?).join(' ')
  end
end
