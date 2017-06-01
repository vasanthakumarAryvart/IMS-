class AddFieldSubtypeToCustomFields < ActiveRecord::Migration
  def change
    add_column :custom_fields, :field_subtype, :string
  end
end
