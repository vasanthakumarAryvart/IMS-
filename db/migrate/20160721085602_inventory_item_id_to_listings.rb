class InventoryItemIdToListings < ActiveRecord::Migration
  def change
    add_column :listings, :inventory_item_id, :integer
    add_column :listing_templates, :inventory_item_id, :integer
  end
end
