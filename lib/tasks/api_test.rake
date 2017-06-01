namespace :api_test do
  task etsy: :environment do
    puts 1
    @etsy = Integrations::Etsy::Etsy.new({})
    request = Etsy.request_token
    Etsy.verification_url
    puts 2
  end

  namespace :ebay do
    task ebay_time: :environment do
      marketplace = Marketplace.where(api_uid: :ebay).first
      account = User.first.accounts.where(marketplace_id: marketplace.id).first
      puts account.integration.logged_in?.inspect
    end

    task categories: :environment do
      marketplace = Marketplace.where(api_uid: :ebay).first
      account = User.first.accounts.where(marketplace_id: marketplace.id).first
      puts account.integration.categories
    end

    task category_fields: :environment do
      marketplace = Marketplace.where(api_uid: :ebay).first
      account = User.first.accounts.where(marketplace_id: marketplace.id).first
      puts account.integration.category_fields(15032) # Mobile category return empty array
      puts account.integration.category_fields(176976) # Memory Card & USB Adapters category return recommendations
    end

    task category_features: :environment do
      marketplace = Marketplace.where(api_uid: :ebay).first
      account = User.first.accounts.where(marketplace_id: marketplace.id).first
      puts account.integration.category_features(15032) # Mobile category return empty array
      puts account.integration.category_features(40176) # Memory Card & USB Adapters category return recommendations
    end

    task verify_item: :environment do
      options = {
          data_fields: {
              title: "test",
              description: "test",
              price: 555.0,
              shipping_price: 5.0,
              data_fields: {
                  listing_format: 'fixed_price',
                  # listing_format: "auction",
              },
              condition_id: "3000",
              listing_duration: "Days_10",
              best_offer: false,
              ships_from: "PA",
              quantity: 66,
              "SPEC: Brand" => "Apple", "SPEC: Model" => "5s", "SPEC: MPN" => "", "SPEC: Network" => "", "SPEC: Contract" => "Without Contract", "SPEC: Operating System" => "iOS", "SPEC: Storage Capacity" => "16GB", "SPEC: Color" => "White", "SPEC: Style" => "Touch Screen", "SPEC: Features" => "", "SPEC: Camera Resolution" => "12.0MP", "SPEC: Bundled Items" => "Adapter, Cable", "SPEC: Cellular Band" => "", "SPEC: Screen Size" => "5\"", "SPEC: Lock Status" => "Factory Unlocked", "SPEC: Memory Card Type" => "", "SPEC: Processor" => "", "SPEC: RAM" => "", "SPEC: Country/Region of Manufacture" => ""
          },
          images: [],
          category_id: 40176,
      }
      puts account_for(:ebay).integration.verify_item(options)
    end

    task add_item: :environment do
      options = {
          category_id: 40176, # Desktop Computers
          data_fields: {
              condition_id: 3000, # used item
              price: 8001,
              discount_price: 5000,
              image_urls: [], # urls for images
              title: 'new super item',
              description: 'item description',
              quantity: 113,
              shipping_price: 3.5,
              item_specifics: [],
              listing_duration: 'Days_10',
              best_offer: false,
              listing_format: 'fixed_price',
              ships_from: 'Philadelphia, Pennsylvania',
          },
          images: [],
          state: {},
      }
      puts account_for(:ebay).integration.add_item(options)
    end

    task update_item: :environment do
      options = {
          condition_id: 1000, # new
          category_id: 40176, # Desktop Computers
          price: 400,
          image_urls: [], # urls for images
          title: 'new super item changed',
          description: 'item description changed',
          quantity: 15,
          shipping_price: 25,
          discount_price: 300,
          item_specifics: [],
          item_id: '110177386546',
          best_offer: false,
      }
      puts account_for(:ebay).integration.update_item(options)
    end

    task delete_item: :environment do
      options = {item_id: '110178857771'}
      puts account_for(:ebay).integration.delete_item(options)
    end

    task get_orders: :environment do
      puts account_for(:ebay).integration.get_orders(DateTime.current - 100.days, DateTime.current).inspect
    end

    task update_orders: :environment do
      options = [{
                     status: 'shipped',
                     order_id: '110175731990-27756498001',
                     notes: 'because chicken mcnuggets windows xp',
                     tracking_code: '12345678913423456789',
                     shipping_carrier_id: 'USPS',
                 }]
      options = [{
                     order_id: '110175731990-27756498001',
                     status: 'cancelled',
                     cancel_reason: 'because chicken mcnuggets windows xp',
                 }]
      puts account_for(:ebay).integration.update_orders(options)
    end

  end

  namespace :amazon do
    task check_login: :environment do
      puts account_for(:amazon).integration.logged_in?.inspect
    end

    task get_orders: :environment do
      puts account_for(:amazon).integration.get_orders(DateTime.current - 7.days, DateTime.current)
    end

    task search_items: :environment do
      puts account_for(:amazon).integration.list_matching_products('iphone 5s')
    end

    task list_order_items: :environment do
      puts account_for(:amazon).integration.order_items('115-3982115-7845052')
      # puts account_for(:amazon).integration.order_items('110-2728535-2773001')
    end

    task add_item: :environment do
      puts account_for(:amazon).integration.add_item({})
    end

    task update_item: :environment do
      puts account_for(:amazon).integration.update_item({})
    end

    task categories: :environment do
      puts account_for(:amazon).integration.categories
    end

    task category_fields: :environment do
      puts account_for(:amazon).integration.category_fields('CE#Phone')
    end

    task update_orders: :environment do
      options = [{
                     status: 'shipped',
                     order_id: '110175731990-27756498001',
                     notes: 'because chicken mcnuggets windows xp',
                     tracking_code: '12345678913423456789',
                     shipping_carrier_id: 'USPS',
                 }]
      options = [{
                     order_id: '110175731990-27756498001',
                     status: 'cancelled',
                     cancel_reason: 'because chicken mcnuggets windows xp',
                 }]
      puts account_for(:amazon).integration.update_items(options)
    end

  end

  def account_for(name)
    marketplace = Marketplace.where(api_uid: name).first
    User.first.accounts.where(marketplace_id: marketplace.id).first
  end
end