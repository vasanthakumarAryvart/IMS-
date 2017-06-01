STDOUT.sync = true

namespace :migrate do
  task :inventory => :environment do
    ItemCategory.transaction do
      mappings = {
          :categories => {},
          :marketplaces => {},
          :sources => {},
          :users => {},
          :items => {},
          :orders => {}
      }

      # categories
      puts "Processing categories..."
      Inventory::Category.all.each { |c|
        category = ItemCategory.create!(:title => c.name)
        mappings[:categories][c.id] = category
      }

      # marketplaces
      puts "Processing marketplaces..."
      Inventory::Marketplace.all.each { |m|
        unless marketplace = Marketplace.where(:name => m.name).first
          marketplace = Marketplace.create!(:name => m.name)
        end
        mappings[:marketplaces][m.id] = marketplace
      }

      # item sources
      puts "Processing sources..."
      Inventory::Login.where(:login_type => 1).each { |s|
        source = ItemSource.create!(
            :name => s.name,
            :short_name => s.short_name,
            :profit_share_percent => s.profit_share_percentage
        )
        mappings[:sources][s.id] = source
      }

      # users
      puts "Processing users..."
      Inventory::Login.where(:login_type => [0, 2]).each { |u|
        password = SecureRandom.hex(10)
        user = User.create!(
            :email => u.login + "@clarabyte.com",
            :first_name => u.first_name,
            :last_name => [u.last_name, u.first_name].reject(&:blank?).first,
            :password => password,
            :confirmed_at => DateTime.now,
            :is_admin => u.login_type == 2,
            :blocked_at => !u.login_enabled? || u.archived? ? DateTime.now : nil,
        )
        mappings[:users][u.id] = user
      }

      # items
      puts "Processing items..."
      default_pin = Warehouse.first.warehouse_pins.first
      total = Inventory::Item.all.count
      Inventory::Item.all.each_with_index { |i, idx|
        item = InventoryItem.create!(
            :icc => i.inventory_control_number,
            :archived => i.archived,
            :serial => i.serial,
            :make => i.make,
            :model => i.model,
            :item_category_id => mappings[:categories][i.category_id].try(:id) || ItemCategory.default.id,
            :item_source_id => mappings[:sources][i.source_id].try(:id),
            :acquisition_cost => i.acquisition_cost || 0,
            :cached_profit_share_percent => i.profit_share_percentage || 0,
            :status => i.status,
            :location => i.location,
            :notes => i.notes,
            :details => {
                :hdd_count => i.hdd_count,
                :hdd_sizes => i.hdd_sizes,
                :ram_gb => i.ram_gb,
                :cpu => i.cpu,
                :cpu_ghz => i.cpu_ghz
            }.reject { |k, v| v.blank? }
        )
        item.warehouse_placements.create!(:warehouse_pin => default_pin, :quantity => i.units || 0)
        mappings[:items][i.id] = item
        puts "#{(100.0 * idx / total).round(2)}%" if idx % 100 == 0
      }

      # orders / sales
      puts "Processing sales..."
      total = Inventory::Sale.all.count
      Inventory::Sale.all.each_with_index { |s, idx|
        next if s.sale_price < 0

        if s.buyer_defined?
          buyer = Buyer.find_by_uid(s.buyer_uid)
          buyer = Buyer.create!(
              :email => s.buyer_email,
              :phone_number => s.buyer_phone,
              :name => s.buyer_name,
              :marketplace => mappings[:marketplaces][s.market_id],
              :uid => s.buyer_uid
          ) unless buyer
        end

        order = Order.create!(
            :account => mappings[:users][s.rep_id].accounts.where(:marketplace => mappings[:marketplaces][s.market_id] || Marketplace.direct).first,
            :buyer => buyer,
            :uid => [s.marketplace_sale_id, "##{s.id}-CLARASALE"].reject(&:blank?).first,
            :order_shipping_detail_attributes => {
                :price => s.shipping_paid,
                :real_price => s.shipping_fee,
                :name => s.buyer_name,
                :phone => s.buyer_phone,
                :city => s.buyer_city,
                :state => s.buyer_state,
                :postal_code => s.buyer_zip,
                :address_line_1 => s.buyer_address1,
                :address_line_2 => s.buyer_address2,
                :buyer_id => buyer.try(:id)
            },
            :payment_status => s.canceled? ? :new : :paid,
            :shipped => !s.canceled?,
            :cancelled => s.canceled?,
            :cancelled_at => s.canceled_date,
            :notes => s.notes,
            :payment_method => s.payment_method,
            :create_timestamp => s.date,
            :update_timestamp => s.canceled_date || s.date,
            :grand_total => s.sale_price + s.shipping_paid,
            :sub_total => s.sale_price,
            :tax => s.sale_tax,
            :manual => true,
            :marketplace_fee => s.marketplace_fee,
            :processing_fee => s.processing_fee
        )

        s.item_sales.each { |is|
          order.order_items.create!(
              :item_price => is.unit_price || 0,
              :quantity => is.units,
              :inventory_item => mappings[:items][is.item_id]
          )
        }

        mappings[:orders][s.id] = order.id
        puts "#{(100.0 * idx / total).round(2)}%" if idx % 100 == 0
      }

      #raise '1234'
    end
  end
end
