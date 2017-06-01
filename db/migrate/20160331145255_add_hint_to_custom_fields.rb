class AddHintToCustomFields < ActiveRecord::Migration
  def change
    add_column :custom_fields, :hint, :string
  end
end
