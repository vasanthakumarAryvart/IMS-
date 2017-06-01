class DashboardController < ApplicationController

  before_filter :authenticate_user!

  def index
  	@dashboards = User.all
    @top_menu_item = :dashboard
    @recent_orders = current_user.orders.order('COALESCE(create_timestamp, orders.created_at) ASC').where('COALESCE(create_timestamp, orders.created_at) > ?', 30.days.ago).includes(:order_shipping_detail, :order_items => [:inventory_item, :account_listing => :listing])
  end

  def shipping
    @top_menu_item = :shipping
  end

end
