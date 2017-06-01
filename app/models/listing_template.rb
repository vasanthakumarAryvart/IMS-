class ListingTemplate < ActiveRecord::Base
  belongs_to :item_category
  has_many :data_fields, :class_name => 'ListingDataField', :inverse_of => :listing_template, :dependent => :destroy
  has_many :images, -> { order(:sort_order) }, :class_name => 'ListingImage', :inverse_of => :listing_template, :dependent => :destroy
  has_many :listings, :dependent => :nullify
  belongs_to :inventory_item

  accepts_nested_attributes_for :data_fields
  accepts_nested_attributes_for :images

  validates_presence_of :item_category

  include CommonDataFields
end
