class ReplaceAccountWithMarketplaceOnListingDataFields < ActiveRecord::Migration
  def change
    add_column :listing_data_fields, :marketplace_id, :integer
    ListingDataField.all.each {|f|
      f.update_attribute(:marketplace_id, f.account.try(:marketplace).try(:id))
    }
    remove_column :listing_data_fields, :account_id
  end
end
