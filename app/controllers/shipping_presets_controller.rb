class ShippingPresetsController < ApplicationController
  # before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter {
    @top_menu_item = :shipping
  }

  EDITABLE_ATTRIBUTES = [:title, :price, :countries]

  layout false

  def new
    @shipping_preset = ShippingPreset.new(:user => current_user, :countries => 'USA')
  end

  def edit
    @shipping_preset = current_user.shipping_presets.find(params[:id])
  end

  def create
    @shipping_preset = ShippingPreset.new
    @shipping_preset.user_id = params[:user_id]
    @shipping_preset.title = params[:title]
    @shipping_preset.provider = params[:provider]
    @shipping_preset.price = params[:price]
    @shipping_preset.description = params[:description]
    @shipping_preset.countries = params[:countries]
     if @shipping_preset.save
        render :json=> {:status => true,:message => "success"}, :status=>200
      else
        render :json=> {:status => false,:message => "already taken"}, :status=>201
      end    

    # shipping_preset = current_user.shipping_presets.build(params[:shipping_preset].permit(EDITABLE_ATTRIBUTES))
    # if shipping_preset.save
    #   flash[:notice] = "Shipping preset created successfully"
    # else
    #   flash[:error] = "Shipping preset could not be created"
    # end
    # redirect_to shipping_path
  end
  def post_shipping
    user = params[:user_id]
    @shipping_presets = ShippingPreset.where(:user_id => user)
    
  end

  def update
    shipping_preset = current_user.shipping_presets.find(params[:id])
    if shipping_preset.update_attributes(params[:shipping_preset].permit(EDITABLE_ATTRIBUTES))
      flash[:notice] = "Shipping preset updated successfully"
    else
      flash[:error] = "Shipping preset could not be updated"
    end
    redirect_to shipping_path
  end

  def destroy
    shipping_preset = current_user.shipping_presets.find(params[:id])
    if shipping_preset.can_delete?
      shipping_preset.destroy
      flash[:notice] = "Shipping preset deleted successfully"
    else
      flash[:error] = "Cannot delete this preset - it is used by some listings. Unassign them in order to delete"
    end
    redirect_to shipping_path
  end
end
