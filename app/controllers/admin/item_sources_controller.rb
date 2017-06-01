class Admin::ItemSourcesController < Admin::AdminController
  before_filter {
    @top_menu_item = :inventory
  }

  EDITABLE_ATTRIBUTES = [:name, :short_name, :profit_share_percent]

  def index
    @sources = ItemSource.order(:name)
  end

  def new
    @source = ItemSource.new
    render :layout => false
  end

  def edit
    @source = ItemSource.find(params[:id])
    render :layout => false
  end

  def create
    source = ItemSource.new(params[:item_source].permit(EDITABLE_ATTRIBUTES))
    if source.save
      flash[:notice] = "Source created successfully"
    else
      flash[:error] = "Source could not be created"
    end
    redirect_to admin_item_sources_path
  end

  def update
    source = ItemSource.find(params[:id])
    if source.update_attributes(params[:item_source].permit(EDITABLE_ATTRIBUTES))
      flash[:notice] = "Source updated successfully"
    else
      flash[:error] = "Source could not be updated"
    end
    redirect_to admin_item_sources_path
  end

  def destroy
    source = ItemSource.find(params[:id])
    source.destroy
    flash[:notice] = "Source deleted successfully"
    redirect_to admin_item_sources_path
  end
end
