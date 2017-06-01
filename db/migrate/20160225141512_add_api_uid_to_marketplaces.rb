class AddApiUidToMarketplaces < ActiveRecord::Migration
  def change
    add_column :marketplaces, :api_uid, :string
  end
end
