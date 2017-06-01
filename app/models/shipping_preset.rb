class ShippingPreset < ActiveRecord::Base
  belongs_to :user
  has_many :listings

  validates_presence_of :user, :title, :price
  validates_numericality_of :price, :greater_than_or_equal_to => 0

  serialize :countries

  after_save :update_affected_listings

  def can_delete?
    self.listings.empty?
  end

  def title_with_details
    extend ActionView::Helpers::NumberHelper
    "#{title} - #{number_to_currency(price)}#{"(#{countries.join(', ')})" if countries.blank?}"
  end

  private

  def update_affected_listings
    listings.map(&:account_listings).flatten.select {|al| al.published? }.map(&:update!)
  end
end
