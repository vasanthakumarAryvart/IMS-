class AddHasApiToMarketplaces < ActiveRecord::Migration
  def change
    add_column :marketplaces, :has_api, :boolean
    Marketplace.all.each { |m|
      m.update_column(:has_api, true) if m.ebay? || m.amazon? || m.shopify? || m.etsy?
    }
  end
end
