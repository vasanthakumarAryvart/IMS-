class CreateListingWarehousePlacements < ActiveRecord::Migration
  def change
    create_table :listing_warehouse_placements do |t|
      t.integer :listing_id
      t.integer :warehouse_pin_id
      t.integer :quantity

      t.timestamps
    end
  end
end
