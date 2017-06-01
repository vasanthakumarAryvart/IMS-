class Admin::AdminController < ApplicationController
  before_filter :require_admin!
  before_filter {
    @top_menu = :admin
    @top_menu_item = :settings
    @body_classes << "admin"
  }

  def dashboard
    @top_menu_item = :dashboard
    @recent_orders = Order.order('COALESCE(create_timestamp, orders.created_at) ASC').where('COALESCE(create_timestamp, orders.created_at) > ?', 30.days.ago).includes(:order_shipping_detail, :order_items => [:inventory_item, :account_listing => :listing])
  end

  def settings
    @top_menu_item = :settings
  end

  def notifications
    @top_menu_item = :settings
  end

end
