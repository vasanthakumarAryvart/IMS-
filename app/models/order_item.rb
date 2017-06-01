class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :account_listing
  belongs_to :inventory_item

  validates_presence_of :order, :item_price, :quantity
  validates_numericality_of :item_price, :greater_than_or_equal_to => 0
  validates_numericality_of :quantity, :greater_than => 0

  scope :listing_resolved, -> { where('account_listing_id IS NOT NULL') }

  def account_listing?
    !!account_listing
  end

  alias has_listing? account_listing?

  def listing
    account_listing.try(:listing)
  end

  def acquisition_cost
    (inventory_item.try(:acquisition_cost) || listing.try(&:cost) || 0) * quantity
  end

  def total
    item_price * quantity
  end
end
