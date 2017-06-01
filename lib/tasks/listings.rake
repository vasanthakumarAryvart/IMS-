namespace :listings do
  task :update_pricing => :environment do
    AccountListing.with_custom_pricing.each { |account_listing|
      # just forward this to Sidekiq
      AccountListing.delay.rescan_pricing_for(account_listing.id, false) if account_listing.needs_repricing?
    }
  end

  task :setup_sale_events => :environment do
    SaleEvent.delay.setup_sale_events
  end
end