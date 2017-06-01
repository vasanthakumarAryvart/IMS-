class AddAccountIdToListingDataFields < ActiveRecord::Migration
  def change
    add_column :listing_data_fields, :account_id, :integer
  end
end
