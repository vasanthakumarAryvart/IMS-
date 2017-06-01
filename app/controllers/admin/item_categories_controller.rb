class Admin::ItemCategoriesController < Admin::AdminController
  before_filter {
    @top_menu_item = :listings
  }

  EDITABLE_ATTRIBUTES = [:title, :parent_category_id]

  def index
    @categories = ItemCategory.top_level_categories.order(:title)
  end

  def new
    @category = ItemCategory.new(:parent_category => ItemCategory.where(:id => params[:parent]).first)
    render :layout => false
  end

  def edit
    @category = ItemCategory.find(params[:id])
    render :layout => false
  end

  def create
    category = ItemCategory.new(params[:item_category].permit(EDITABLE_ATTRIBUTES))
    if category.save
      flash[:notice] = "Category created successfully"
    else
      flash[:error] = "Category could not be created"
    end
    redirect_to admin_item_categories_path
  end

  def update
    category = ItemCategory.find(params[:id])
    if category.update_attributes(params[:item_category].permit(EDITABLE_ATTRIBUTES))
      flash[:notice] = "Category updated successfully"
    else
      flash[:error] = "Category could not be updated"
    end
    redirect_to admin_item_categories_path
  end

  def destroy
    category = ItemCategory.find(params[:id])
    if category.can_delete?
      category.destroy
      flash[:notice] = "Category deleted successfully"
    else
      flash[:error] = "Cannot delete this category - it is used by some listings or has child categories. Unassign them in order to delete"
    end
    redirect_to admin_item_categories_path
  end
end
