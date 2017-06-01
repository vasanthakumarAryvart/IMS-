class CreateCustomFieldMappings < ActiveRecord::Migration
  def change
    create_table :custom_field_mappings do |t|
      t.integer :custom_field_id
      t.integer :marketplace_id
      t.string :marketplace_field
      t.string :marketplace_category
      t.boolean :required

      t.timestamps
    end
  end
end
