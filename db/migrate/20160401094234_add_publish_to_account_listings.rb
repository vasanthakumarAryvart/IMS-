class AddPublishToAccountListings < ActiveRecord::Migration
  def change
    add_column :account_listings, :publish, :boolean
  end
end
