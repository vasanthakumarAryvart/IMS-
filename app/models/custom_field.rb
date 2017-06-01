class CustomField < ActiveRecord::Base
  has_many :custom_field_mappings, :dependent => :destroy
  has_many :listing_data_fields, :dependent => :destroy
  belongs_to :item_category

  validates_presence_of :item_category, :name
  validates_uniqueness_of :name, :scope => :item_category_id
  validates_presence_of :field_type, :if => Proc.new { !self.set_per_marketplace? }

  serialize :field_options

  DEFAULT_FIELDS = [
      {
          :name => "Title",
          :hint => 'Listing Title',
          :field_type => 'string',
          :sort_order => 0
      },
      {
          :name => "Description",
          :hint => 'Listing Description',
          :field_type => 'text',
          :sort_order => 1
      },
      {
          :name => "Make",
          :hint => 'Item Vendor / Make / Manufacturer',
          :field_type => 'string',
          :sort_order => 2
      },
      {
          :name => "Model",
          :hint => 'Item Model',
          :field_type => 'string',
          :sort_order => 3
      },
      {
          :name => "Price",
          :hidden => true,
          :not_for_template => true,
          :set_per_marketplace => true,
          :sort_order => 4
      },
      {
          :name => "Shipping Price",
          :hidden => true,
          :not_for_template => true,
          :set_per_marketplace => true,
          :sort_order => 5
      },
      {
          :name => "Discount Price",
          :hidden => true,
          :not_for_template => true,
          :set_per_marketplace => true,
          :sort_order => 6
      },
      {
          :name => "Quantity",
          :hidden => true,
          :not_for_template => true,
          :field_type => 'int',
          :sort_order => 7
      },
  ]

  ARRAY_FIELD_TYPES = %w{string text int float image}
  FIELD_TYPES = %w{string text int float bool enum image array}

  def required?
    custom_field_mappings.map(&:required?).include?(true)
  end

  def can_delete?
    !default_field?
  end

  def default_field?
    DEFAULT_FIELDS.map { |f| f[:name] }.include?(self.name)
  end

  def title_field?
    name.downcase == 'title'
  end

  def description_field?
    name.downcase == 'description'
  end

  def make_field?
    %w{make manufacturer vendor}.include?(name.downcase)
  end

  def model_field?
    name.downcase == 'model'
  end

  def field_options
    result = self[:field_options] || []
    if result.empty?
      other_options = custom_field_mappings.map(&:marketplace_field_options).compact
      result = other_options[0] if other_options.length == 1
    end
    result
  end

  def custom_field_mapping_for(marketplace)
    marketplace = Marketplace.find_by_id(marketplace) unless marketplace.is_a?(Marketplace)
    raise 'Marketplace not specified' unless marketplace
    custom_field_mappings.find { |m| m.marketplace == marketplace }
  end

  def set_per_marketplace_editable?
    new_record?
  end
end
