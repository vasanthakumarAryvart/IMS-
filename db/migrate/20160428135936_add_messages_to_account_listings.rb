class AddMessagesToAccountListings < ActiveRecord::Migration
  def change
    add_column :account_listings, :messages, :text
  end
end
