class AddPriceUpdatedAtToAccountListings < ActiveRecord::Migration
  def change
    add_column :account_listings, :price_updated_at, :datetime
  end
end
