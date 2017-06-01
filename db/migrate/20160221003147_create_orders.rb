class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :account_id
      t.integer :buyer_id
      t.string :uid
      t.decimal :total_price, :precision => 16, :scale => 4
      t.text :ship_to

      t.timestamps
    end
  end
end
