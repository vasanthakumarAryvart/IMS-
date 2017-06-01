class ItemCategory < ActiveRecord::Base
  has_many :custom_fields, -> { order(:sort_order) }, :dependent => :destroy
  belongs_to :parent_category, :class_name => 'ItemCategory'
  has_many :child_categories, :class_name => 'ItemCategory', :foreign_key => 'parent_category_id', :dependent => :destroy
  has_many :listings, :dependent => :restrict_with_exception
  has_many :listing_templates, :dependent => :restrict_with_exception
  has_many :sale_events, :dependent => :destroy
  has_many :marketplace_category_mappings, :dependent => :destroy
  has_many :inventory_items, :dependent => :restrict_with_exception

  validates_presence_of :title

  scope :top_level_categories, -> { where(:parent_category_id => nil) }

  def can_delete?
    child_categories.empty? && listings.empty? && listing_templates.empty? && inventory_items.empty?
  end

  def recursive_child_categories
    (child_categories + child_categories.map(&:recursive_child_categories)).flatten.uniq
  end

  def marketplace_category_mapping_for(marketplace)
    marketplace = Marketplace.find_by_id(marketplace) unless marketplace.is_a?(Marketplace)
    raise 'Marketplace not specified' unless marketplace
    marketplace_category_mappings.where(:marketplace_id => marketplace.id).first
  end

  def ensure_default_fields!
    CustomField::DEFAULT_FIELDS.each { |df|
      self.custom_fields.create!(df) unless self.custom_fields.find { |f| f.name == df[:name] }
    }
  end

  def self.default
    ItemCategory.find_or_create_by!(:title => 'Default', :parent_category_id => nil)
  end
end
