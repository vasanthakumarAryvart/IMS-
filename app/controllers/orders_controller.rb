class OrdersController < ApplicationController
  before_filter :authenticate_user!
  before_filter {
    @top_menu_item = :orders
  }
  before_filter :set_order, :only => [:update, :edit, :destroy]

  EDITABLE_ATTRIBUTES = [
      :account_id,
      :buyer_id,
      :manual,

      :uid,
      :payment_status,
      :notes,
      :payment_method,

      :create_timestamp,
      :update_timestamp,

      :grand_total,
      :sub_total,
      :tax,

      :marketplace_fee,
      :processing_fee,

      :shipped,
      :cancelled,
      :paid_at,
      :shipped_at,
      :refunded_at,
      :cancelled_at,
      :cancel_reason,
      :order_shipping_detail_attributes => [
          :price,
          :real_price,
          :name,
          :phone,
          :city,
          :state,
          :postal_code,
          :address_line_1,
          :address_line_2,
          :buyer_id,
          :tracking_code,
          :carrier
      ],
      :buyer_attributes => [
          :email,
          :name,
          :phone_number
      ]
  ]

  def index
    if params.keys.include?('refresh')
      current_user.enqueue_refresh_orders!
      flash[:success] = 'Initialized manual orders refresh for your accounts. This may take a few minutes'
      redirect_to :orders
    else
      @filter = params[:filter] || {}
      @orders = current_user.orders.order('COALESCE(create_timestamp, orders.created_at) DESC')
      unless @filter.blank?
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

  def new
    @order = Order.new(
        :create_timestamp => DateTime.now,
        :order_shipping_detail => OrderShippingDetail.new,
        :buyer => Buyer.new,
        :manual => true
    )
    render :layout => false
  end

  def edit
    @order.buyer = @order.build_buyer unless @order.buyer
    render :layout => false
  end

  def create
    @order = Order.new(params[:order].permit(EDITABLE_ATTRIBUTES))
    existing_buyer = Buyer.where(:uid => @order.buyer.generate_uid).first
    @order.buyer = existing_buyer if existing_buyer
    if @order.save!
      flash[:notice] = "Order created successfully"
    else
      flash[:alert] = "Order could not be created. Please check your inputs"
    end
    redirect_to :back
  end

  def update
    if @order.update_attributes!(params[:order].permit(EDITABLE_ATTRIBUTES))
      flash[:notice] = "Order updated successfully"
    else
      flash[:alert] = "Order could not be updated. Please check your inputs"
    end
    redirect_to :back
  end

  def destroy
    @order.destroy
    flash[:notice] = "Order deleted"
    redirect_to :back
  end

  private

  def set_order
    @order = (current_user.is_admin? ? Order : current_user.orders).where(:id => params[:id]).first
    if @order
      unless @order.manual?
        flash[:alert] = "Only manually created orders can be managed"
        redirect_to :orders
      end
    else
      flash[:alert] = "Order not found or access restricted"
      redirect_to :orders
    end
  end

end
