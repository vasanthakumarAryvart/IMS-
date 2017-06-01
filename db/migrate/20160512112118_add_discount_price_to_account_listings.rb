class AddDiscountPriceToAccountListings < ActiveRecord::Migration
  def change
    add_column :account_listings, :discount_price, :decimal, :precision => 16, :scale => 4
  end
end
