class WarehousePinsController < ApplicationController
  before_filter :authenticate_user!
  before_filter {
    @warehouse = current_user.warehouses.find(params[:warehouse_id])
    render :status => :not_found unless @warehouse
  }

  layout false

  EDITABLE_ATTRIBUTES = [:title, :location, :location_on_plan => [:x, :y, :width]]

  def new
    @warehouse_pin = WarehousePin.new(:warehouse => @warehouse)
  end

  def edit
    @warehouse_pin = @warehouse.warehouse_pins.find(params[:id])
  end

  def create
    warehouse_pin = @warehouse.warehouse_pins.build(params[:warehouse_pin].permit(EDITABLE_ATTRIBUTES))
    if warehouse_pin.save
      flash[:notice] = "Warehouse Pin created successfully"
    else
      flash[:error] = "Warehouse Pin could not be created"
    end
    redirect_to warehouse_path(@warehouse)
  end

  def update
    warehouse_pin = @warehouse.warehouse_pins.find(params[:id])
    if warehouse_pin.update_attributes(params[:warehouse_pin].permit(EDITABLE_ATTRIBUTES))
      flash[:notice] = "Warehouse Pin updated successfully"
    else
      flash[:error] = "Warehouse Pin could not be updated"
    end
    redirect_to warehouse_path(@warehouse)
  end

  def destroy
    warehouse_pin = @warehouse.warehouse_pins.find(params[:id])
    if warehouse_pin.can_delete?
      warehouse_pin.delete
      flash[:notice] = "Warehouse Pin deleted successfully"
    else
      flash[:error] = "Cannot delete this warehouse pin - it is used by some listings. Unassign them in order to delete"
    end
    redirect_to warehouse_path(@warehouse)
  end
end
