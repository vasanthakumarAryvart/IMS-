class OrderItemsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_order
  before_filter :set_item, :only => [:update, :edit, :destroy]

  EDITABLE_ATTRIBUTES = [
      :item_price,
      :quantity,
      :inventory_item_id
  ]

  def new
    @item = @order.order_items.build(:quantity => 1)
    render :layout => false
  end

  def edit
    render :layout => false
  end

  def create
    @item = @order.order_items.build(params[:order_item].permit(EDITABLE_ATTRIBUTES))
    if @item.save
      render :partial => 'orders/details', :locals => { :order => @order }
    else
      render :text => 'Could not save order item. Please verify your inputs', :status => :unprocessable_entity
    end
  end

  def update
    if @item.update_attributes(params[:order_item].permit(EDITABLE_ATTRIBUTES))
      render :partial => 'orders/details', :locals => { :order => @order }
    else
      render :text => 'Could not save order item. Please verify your inputs', :status => :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    render :partial => 'orders/details', :locals => { :order => @order }
  end

  def inventory_search
    render :json => InventoryItem.where("id like ? OR make like ? OR model like ? OR icc like ? OR serial like ?", *(["%#{params[:term]}%"] * 5)).map { |i|
      {
          :value => i.id,
          :label => "##{i.id} - #{i.title}"
      }
    }
  end

  private

  def set_order
    @order = (current_user.is_admin? ? Order : current_user.orders).where(:id => params[:order_id]).first
    unless @order && @order.manual?
      render :text => "You don't have edit access to this order", :status => :unprocessable_entity
    end
  end

  def set_item
    @item = @order.order_items.where(:id => params[:id]).first
    unless @item
      render :text => "You don't have edit access to this order item", :status => :unprocessable_entity
    end
  end

end
