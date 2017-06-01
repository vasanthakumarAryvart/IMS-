class CreateMarketplaceCategoryMappings < ActiveRecord::Migration
  def change
    create_table :marketplace_category_mappings do |t|
      t.integer :item_category_id
      t.integer :marketplace_id
      t.string :marketplace_category
      t.string :marketplace_category_name

      t.timestamps null: false
    end

    CustomFieldMapping.delete_all

    remove_column :custom_field_mappings, :marketplace_id
    remove_column :custom_field_mappings, :marketplace_category
    remove_column :custom_field_mappings, :marketplace_category_name
    add_column :custom_field_mappings, :marketplace_category_mapping_id, :integer
  end
end
