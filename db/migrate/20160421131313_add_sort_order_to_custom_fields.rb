class AddSortOrderToCustomFields < ActiveRecord::Migration
  def change
    add_column :custom_fields, :sort_order, :integer, :default => 9999999
    add_column :custom_fields, :hidden, :boolean
  end
end
