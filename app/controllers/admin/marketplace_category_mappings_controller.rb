class Admin::MarketplaceCategoryMappingsController < Admin::AdminController
  before_filter {
    @top_menu_item = :categories
  }
  before_filter {
    @category = ItemCategory.find(params[:item_category_id])
  }

  ATTRIBUTES_FOR_CREATE = [:marketplace_category, :marketplace_category_name, :item_category_id, :marketplace_id]
  ATTRIBUTES_FOR_UPDATE = ATTRIBUTES_FOR_CREATE - [:item_category_id, :marketplace_id]

  layout false

  def new
    @marketplace_category_mapping = @category.marketplace_category_mappings.build(:marketplace => Marketplace.find(params[:marketplace_id]))
  end

  def edit
    @marketplace_category_mapping = @category.marketplace_category_mappings.find(params[:id])
  end

  def create
    marketplace_category_mapping = @category.marketplace_category_mappings.build(params[:marketplace_category_mapping].permit(ATTRIBUTES_FOR_CREATE))
    if marketplace_category_mapping.save
      flash[:notice] = "Marketplace category mapping created successfully"
    else
      flash[:error] = "Marketplace category mapping could not be created"
    end
    redirect_to admin_item_categories_path
  end

  def update
    marketplace_category_mapping = @category.marketplace_category_mappings.find(params[:id])
    if marketplace_category_mapping.update_attributes(params[:marketplace_category_mapping].permit(ATTRIBUTES_FOR_CREATE))
      flash[:notice] = "Marketplace category mapping updated successfully"
    else
      flash[:error] = "Marketplace category mapping could not be updated"
    end
    redirect_to admin_item_categories_path
  end

  def destroy
    marketplace_category_mapping = @category.marketplace_category_mappings.find(params[:id])
    marketplace_category_mapping.destroy
    flash[:notice] = "Marketplace category mapping deleted successfully"
    redirect_to admin_item_categories_path
  end

  def marketplace_subcategories
    @marketplace = Marketplace.find(params[:marketplace_id])
    @integration = current_user.integration_for(@marketplace)
    render :json => @integration.categories(params[:category_id])
  end
end
