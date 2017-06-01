class RemoveFieldTypeFromCustomFields < ActiveRecord::Migration
  def change
    remove_column :custom_fields, :field_type
  end
end
