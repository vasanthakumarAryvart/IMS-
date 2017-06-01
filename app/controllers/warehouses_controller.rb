class WarehousesController < ApplicationController
  # before_filter :authenticate_user!
    skip_before_filter :verify_authenticity_token

  before_filter {
    @top_menu_item = :shipping
  }

  layout false
 
  EDITABLE_ATTRIBUTES = [:title, :address, :description, :floor_plan]

  def show
    @warehouse = current_user.warehouses.find(params[:id])
    render :layout => 'application'
  end
   def post_warehouse
    uk = params[:lov]
    user = params[:user_id]
    puts"=======#{:user_id}======="
    puts"==4444444444444====#{uk}======"
        puts"=====3333333==#{params}======="

    @warehouses = Warehouse.where(:user_id => user)
        puts"========fddfafa======"

    
  end

  def new
    @warehouse = Warehouse.new(:user => current_user)
  end

  def edit
    @warehouse = current_user.warehouses.find(params[:id])
  end
 
  def create
    # warehouse = current_user.warehouses.build(params[:warehouse].permit(EDITABLE_ATTRIBUTES))
    # if warehouse.save
    #   flash[:notice] = "Warehouse created successfully"
    # else
    #   flash[:error] = "Warehouse could not be created"
    # end
    # redirect_to shipping_path
       # @warehouse = Warehouse.new

         # respond_to do |format|
         #   if @warehouse.save
         #    format.html { redirect_to warehouse_url, notice: 'warehouse was successfully created.' }
         #    format.json { render :show, status: :created, location: @warehouse }
         #   else  
         #    format.html { render :new }
         #    format.json { render json: @product.errors, status: :unprocessable_entity }
         #    end
         # end
    @warehouse = Warehouse.new
    puts"-===-=-=-=-=-=-=----------"
    @warehouse.user_id = params[:user_id]
    @warehouse.title = params[:title]
    @warehouse.address = params[:address]
    @warehouse.description = params[:description]
    @warehouse.floor_plan = params[:floor_plan]
        puts"==111111111======#{params[:floor_plan]}=================-"

     if @warehouse.save
        render :json=> {:status => true,:message => "success"}, :status=>200
      else
        render :json=> {:status => false,:message => "failure"}, :status=>201
      end    
  end

  def update
    warehouse = current_user.warehouses.find(params[:id])
    if warehouse.update_attributes(params[:warehouse].permit(EDITABLE_ATTRIBUTES))
      flash[:notice] = "Warehouse updated successfully"
    else
      flash[:error] = "Warehouse could not be updated"
    end
    redirect_to shipping_path
  end

  def destroy
    warehouse = current_user.warehouses.find(params[:id])
    if warehouse.can_delete?
      warehouse.destroy
      flash[:notice] = "Warehouse deleted successfully"
    else
      flash[:error] = "Cannot delete this warehouse - it holds some listings. Unassign them in order to delete"
    end
    redirect_to shipping_path
  end
end
