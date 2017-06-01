class CreateWarehouses < ActiveRecord::Migration
  def change
    create_table :warehouses do |t|
      t.string :title
      t.integer :user_id
      t.string :address
      t.text :description

      t.timestamps
    end
    add_attachment :warehouses, :floor_plan
  end
end
