class RenameTypeToListingTypeOnAccountListings < ActiveRecord::Migration
  def change
    rename_column :account_listings, :type, :listing_type
  end
end
