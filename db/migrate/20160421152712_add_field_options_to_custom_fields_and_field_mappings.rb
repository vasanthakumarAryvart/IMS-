class AddFieldOptionsToCustomFieldsAndFieldMappings < ActiveRecord::Migration
  def change
    rename_column :custom_fields, :simple_field_type, :field_type
    add_column :custom_fields, :field_options, :text
    add_column :custom_field_mappings, :marketplace_field_type, :string
    add_column :custom_field_mappings, :marketplace_field_options, :text
  end
end
