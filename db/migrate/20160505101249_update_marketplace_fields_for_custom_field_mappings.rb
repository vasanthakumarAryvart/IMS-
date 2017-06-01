class UpdateMarketplaceFieldsForCustomFieldMappings < ActiveRecord::Migration
  def change
    remove_column :custom_field_mappings, :marketplace_field_options
    remove_column :custom_field_mappings, :marketplace_field_type
    add_column :custom_field_mappings, :marketplace_field_config, :text
  end
end
