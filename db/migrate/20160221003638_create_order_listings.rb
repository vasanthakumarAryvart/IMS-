class CreateOrderListings < ActiveRecord::Migration
  def change
    create_table :order_listings do |t|
      t.integer :order_id
      t.integer :account_listing_id
      t.decimal :item_price, :precision => 16, :scale => 4
      t.integer :quantity

      t.timestamps
    end
  end
end
