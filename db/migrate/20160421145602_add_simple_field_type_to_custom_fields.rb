class AddSimpleFieldTypeToCustomFields < ActiveRecord::Migration
  def change
    add_column :custom_fields, :simple_field_type, :string
  end
end
