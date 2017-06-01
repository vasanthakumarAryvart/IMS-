class UpgradeOrderListingsToOrderItems < ActiveRecord::Migration
  def change
    rename_table :order_listings, :order_items
    add_column :order_items, :inventory_item_id, :integer
  end
end
