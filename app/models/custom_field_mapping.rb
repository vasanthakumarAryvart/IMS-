class CustomFieldMapping < ActiveRecord::Base
  belongs_to :custom_field
  belongs_to :marketplace_category_mapping

  validates_presence_of :custom_field,
                        :marketplace_field,
                        :marketplace_field_config,
                        :marketplace_category_mapping

  serialize :marketplace_field_config

  scope :for_marketplace, ->(marketplace) {
    marketplace = Marketplace.find_by_id(marketplace) unless marketplace.is_a?(Marketplace)
    raise 'Marketplace not specified' unless marketplace
    joins(:marketplace_category_mapping).where('marketplace_category_mappings.marketplace_id' => marketplace.id)
  }

  delegate :marketplace, :marketplace_category, :marketplace_category_name, :to => :marketplace_category_mapping

  def marketplace_field_config
    (self[:marketplace_field_config] || {}).with_indifferent_access
  end

  def marketplace_field_type
    marketplace_field_config[:data_type]
  end

  def marketplace_field_subtype
    marketplace_field_config[:data_subtype]
  end

  def marketplace_field_options
    marketplace_field_config[:data_options]
  end
end
