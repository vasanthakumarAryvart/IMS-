class Admin::InventoryItemsController < Admin::AdminController
  before_filter {
    @top_menu_item = :inventory
  }

  EDITABLE_ATTRIBUTES = [
      :icc, :serial, :make, :model, :item_category_id, :item_source_id,
      :status, :location, :notes, :acquisition_cost, :cached_profit_share_percent,
      :warehouse_placements_attributes => [
          :id,
          :warehouse_pin_id,
          :quantity,
          :_destroy
      ],
      :details => {}
  ]

  def index
    @filter = params[:filter] || {}
    @items = InventoryItem.order('id DESC')
    unless @filter.blank?
      # active/inactive
      @items = @items.where('COALESCE(archived, false) = ?', @filter[:active].to_i == 0)

      # source
      @items = @items.where(:item_source_id => @filter[:source]) unless @filter[:source].blank?

      # status
      @items = @items.where(:status => @filter[:status]) unless @filter[:status].blank?

      # term
      @items = @items.where("id like ? OR notes like ? OR make like ? OR model like ? OR icc like ? OR serial like ? or location like ? OR status like ?", *(["%#{@filter[:term]}%"] * 8)) unless @filter[:term].blank?

      # category
      category = ItemCategory.find_by_id(@filter[:category]) unless @filter[:category].blank?
      @items = @items.where(:item_category_id => [category.id] + category.recursive_child_categories.map(&:id)) if category

      @items = @items.paginate(:page => params[:page].try(:to_i))
    end
    render :layout => false if @filter[:ajax]
  end

  def new
    @item = InventoryItem.new
    render :layout => false
  end

  def edit
    @item = InventoryItem.find(params[:id])
    render :layout => false
  end

  def create
    item = InventoryItem.new(item_params)
    if item.save
      flash[:notice] = "Item created successfully"
    else
      flash[:error] = "Item could not be created"
    end
    redirect_to admin_inventory_items_path
  end

  def update
    item = InventoryItem.find(params[:id])
    if item.update_attributes(item_params)
      flash[:notice] = "Item updated successfully"
    else
      flash[:error] = "Item could not be updated"
    end
    redirect_to admin_inventory_items_path
  end

  def destroy
    item = InventoryItem.find(params[:id])
    item.archive!
    flash[:notice] = "Item archived successfully"
    redirect_to admin_inventory_items_path
  end

  private

  def item_params
    params.require(:inventory_item).permit(EDITABLE_ATTRIBUTES).tap do |whitelisted|
      whitelisted[:details] = params[:inventory_item][:details]
    end
  end
end
