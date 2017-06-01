class CreateWarehousePins < ActiveRecord::Migration
  def change
    create_table :warehouse_pins do |t|
      t.integer :warehouse_id
      t.string :title
      t.string :location
      t.string :location_on_plan

      t.timestamps
    end
  end
end
