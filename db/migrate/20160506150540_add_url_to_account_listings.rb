class AddUrlToAccountListings < ActiveRecord::Migration
  def change
    add_column :account_listings, :url, :string
  end
end
