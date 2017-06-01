class AddIntegrationStateToAccountListings < ActiveRecord::Migration
  def change
    add_column :account_listings, :integration_state, :text
  end
end
