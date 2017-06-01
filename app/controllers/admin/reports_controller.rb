class Admin::ReportsController < Admin::AdminController
  before_filter {
    @top_menu_item = :reports
  }

  def sales
    @filter = params[:filter] || {}
    unless @filter.blank?
      @orders = Order.order('COALESCE(create_timestamp, orders.created_at) DESC')

      # user
      @orders = User.find(@filter[:user]).orders.order('COALESCE(create_timestamp, orders.created_at) DESC') unless @filter[:user].blank?
      # marketplace
      @orders = @orders.joins(:account => :marketplace).where('marketplaces.name = ?', @filter[:marketplace]) unless @filter[:marketplace].blank?
      # dates
      @orders = @orders.where('COALESCE(create_timestamp, orders.created_at) > ?', Date.parse(@filter[:date_from])) if Date.parse(@filter[:date_from]) rescue false
      @orders = @orders.where('COALESCE(create_timestamp, orders.created_at) < ?', Date.parse(@filter[:date_to])) if Date.parse(@filter[:date_to]) rescue false

      @orders = @orders.includes(:order_shipping_detail, :order_items => [:inventory_item, :account_listing => :listing])

      # grouping
      @groups = @orders.group_by { |o|
        case @filter[:group].try(:to_sym)
          when :month
            o.create_timestamp.to_date.strftime("%B %Y")
          when :year
            o.create_timestamp.to_date.strftime("Year %Y")
          else # blank => :day
            o.create_timestamp.to_date.strftime("%B %d, %Y")
        end
      }.map { |g, orders|
        {
            :title => g,
            :count => orders.length,
            :revenue => orders.select(&:grand_total).map(&:grand_total).inject(&:+),
            :avg_order => orders.select(&:grand_total).map(&:grand_total).inject(&:+) / orders.length,
            :profit_share => orders.map(&:profit_share_deductions).inject(&:+),
            :net => orders.map(&:net_profit).inject(&:+),
        }
      }
    end
    render :layout => false if @filter[:ajax]
  end

  def sold_listings
    @filter = params[:filter] || {}
    unless @filter.blank?
      @orders = Order.order('COALESCE(create_timestamp, orders.created_at) DESC')

      # user
      @orders = User.find(@filter[:user]).orders.order('COALESCE(create_timestamp, orders.created_at) DESC') unless @filter[:user].blank?
      # marketplace
      @orders = @orders.joins(:account => :marketplace).where('marketplaces.name = ?', @filter[:marketplace]) unless @filter[:marketplace].blank?
      # dates
      @orders = @orders.where('COALESCE(create_timestamp, orders.created_at) > ?', Date.parse(@filter[:date_from])) if Date.parse(@filter[:date_from]) rescue false
      @orders = @orders.where('COALESCE(create_timestamp, orders.created_at) < ?', Date.parse(@filter[:date_to])) if Date.parse(@filter[:date_to]) rescue false

      @orders = @orders.includes(:order_shipping_detail, :order_items => [:inventory_item, :account_listing => :listing])

      # grouping
      @groups = @orders.map { |o|
        o.order_items.map { |ol|
          if ol.has_listing?
            {
                item_title: ol.listing.title,
                listing: ol.listing,
                price: ol.item_price
            }
          elsif ol.inventory_item
            {
                item_title: ol.inventory_item.title,
                price: ol.item_price
            }
          end
        }.compact
      }.flatten.group_by { |ol| ol[:item_title] }.map { |title, details|
        {
            :item_title => title,
            :count => details.length,
            :revenue => details.map { |d| d[:price] }.compact.inject(&:+)
        }
      }.sort_by { |g|
        -g[:count]
      }
    end
    render :layout => false if @filter[:ajax]
  end

  def performance
    @filter = params[:filter] || {}
    @orders = Order.order('COALESCE(create_timestamp, orders.created_at) DESC')
    if @filter[:ajax]
      users = User.all
      unless @filter[:keyword].blank?
        users = User.where("id = ? OR first_name like ? OR last_name like ? OR email like ?", @filter[:keyword], *(["%#{@filter[:keyword]}%"] * 3))
      end
      @stats = users.map { |user|
        {
            :user => user,
            :orders => user.orders.where('COALESCE(create_timestamp, orders.created_at) BETWEEN ? AND ?', Date.parse(@filter[:date_from]), Date.parse(@filter[:date_to])).includes(:order_shipping_detail, :order_items => [:inventory_item, :account_listing => :listing]),
            :listings => user.listings.where('created_at BETWEEN ? AND ?', Date.parse(@filter[:date_from]), Date.parse(@filter[:date_to]))
        }
      }
      render :layout => false
    end
  end

end
