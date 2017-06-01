class MarketplaceCategoryMapping < ActiveRecord::Base
  belongs_to :item_category
  belongs_to :marketplace
  has_many :custom_field_mappings, :dependent => :destroy

  validates_presence_of :item_category, :marketplace, :marketplace_category
end
