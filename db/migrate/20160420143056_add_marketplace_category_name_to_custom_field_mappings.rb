class AddMarketplaceCategoryNameToCustomFieldMappings < ActiveRecord::Migration
  def change
    add_column :custom_field_mappings, :marketplace_category_name, :string
  end
end
