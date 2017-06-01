class CreateAccountListings < ActiveRecord::Migration
  def change
    create_table :account_listings do |t|
      t.integer :account_id
      t.integer :listing_id
      t.string :type
      t.string :status
      t.decimal :price, :precision => 16, :scale => 4
      t.decimal :min_price, :precision => 16, :scale => 4
      t.string :pricing_type
      t.string :formula
      t.string :relative_price
      t.string :uid

      t.timestamps
    end
  end
end
