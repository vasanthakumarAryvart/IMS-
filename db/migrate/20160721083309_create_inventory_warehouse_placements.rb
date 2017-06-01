class CreateInventoryWarehousePlacements < ActiveRecord::Migration
  def change
    create_table :inventory_warehouse_placements do |t|
      t.integer :inventory_item_id
      t.integer :warehouse_pin_id
      t.integer :quantity

      t.timestamps null: false
    end
  end
end
