class RenameTypeToFieldTypeOnCustomFields < ActiveRecord::Migration
  def change
    rename_column :custom_fields, :type, :field_type
  end
end
