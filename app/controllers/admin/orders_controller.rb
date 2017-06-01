class Admin::OrdersController < Admin::AdminController
  before_filter {
    @top_menu_item = :orders
  }

  def index
    @filter = params[:filter] || {}
    @orders = Order.order('COALESCE(create_timestamp, orders.created_at) DESC')
    unless @filter.blank?
      # user
      @orders = User.find(@filter[:user]).orders.order('COALESCE(create_timestamp, orders.created_at) DESC') unless @filter[:user].blank?
      # marketplace
      @orders = @orders.joins(:account => :marketplace).where('marketplaces.name = ?', @filter[:marketplace]) unless @filter[:marketplace].blank?
      # dates
      @orders = @orders.where('COALESCE(create_timestamp, orders.created_at) > ?', Date.parse(@filter[:date_from])) if Date.parse(@filter[:date_from]) rescue false
      @orders = @orders.where('COALESCE(create_timestamp, orders.created_at) < ?', Date.parse(@filter[:date_to])) if Date.parse(@filter[:date_to]) rescue false

      @orders = @orders.includes(:order_shipping_detail, :order_items => [:inventory_item, :account_listing => :listing])

      # status
      @orders = @orders.select { |o| o.status.to_s.downcase == @filter[:status].downcase } unless @filter[:status].blank?

      @orders = @orders.paginate(:page => params[:page].try(:to_i))
    end
    render :layout => false if @filter[:ajax]
  end

end
