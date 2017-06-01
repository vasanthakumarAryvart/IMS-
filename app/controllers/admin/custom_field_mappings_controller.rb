class Admin::CustomFieldMappingsController < Admin::AdminController
  before_filter {
    @top_menu_item = :categories
  }
  before_filter {
    @category = ItemCategory.find(params[:item_category_id])
    @custom_field = @category.custom_fields.find(params[:custom_field_id])
  }

  ATTRIBUTES_FOR_CREATE = [:marketplace_category_mapping_id, :marketplace_field, :required, :marketplace_field_config]
  ATTRIBUTES_FOR_UPDATE = ATTRIBUTES_FOR_CREATE - [:marketplace_category_mapping_id]

  layout false

  def new
    marketplace_category_mapping = MarketplaceCategoryMapping.find(params[:marketplace_category_mapping_id])
    raise "Invalid action" unless marketplace_category_mapping.item_category == @category
    @custom_field_mapping = @custom_field.custom_field_mappings.build(:marketplace_category_mapping => marketplace_category_mapping)
    # get marketplace integration and retrieve category fields
    @integration = current_user.integration_for(marketplace_category_mapping.marketplace)
    @category_fields = @integration.category_fields(marketplace_category_mapping.marketplace_category).sort_by { |f| f[:required] ? 0 : 1 }
    # remove fields we already mapped
    @category_fields.reject! { |f|
      marketplace_category_mapping.custom_field_mappings.map { |m| m.marketplace_field }.include?(f[:name])
    }
  end

  def edit
    @custom_field_mapping = @custom_field.custom_field_mappings.find(params[:id])
    # get marketplace integration and retrieve category fields
    @integration = current_user.integration_for(@custom_field_mapping.marketplace)
    @category_fields = @integration.category_fields(@custom_field_mapping.marketplace_category_mapping.marketplace_category).sort_by { |f| f[:required] ? 0 : 1 }
    # remove fields we already mapped
    @category_fields.reject! { |f|
      (@custom_field_mapping.marketplace_category_mapping.custom_field_mappings - [@custom_field_mapping]).map { |m| m.marketplace_field }.include?(f[:name])
    }
  end

  def create
    custom_field_mapping = @custom_field.custom_field_mappings.build(params[:custom_field_mapping].permit(ATTRIBUTES_FOR_CREATE))
    (custom_field_mapping.marketplace_field_config = JSON.parse params[:custom_field_mapping].delete(:marketplace_field_config)) rescue nil
    if custom_field_mapping.save
      flash[:notice] = "Custom field mapping created successfully"
    else
      flash[:error] = "Custom field mapping could not be created"
    end
    redirect_to admin_item_category_custom_fields_path(@category)
  end

  def update
    custom_field_mapping = @custom_field.custom_field_mappings.find(params[:id])
    (custom_field_mapping.marketplace_field_config = JSON.parse params[:custom_field_mapping].delete(:marketplace_field_config)) rescue nil
    if custom_field_mapping.update_attributes(params[:custom_field_mapping].permit(ATTRIBUTES_FOR_UPDATE))
      flash[:notice] = "Custom field mapping updated successfully"
    else
      flash[:error] = "Custom field mapping could not be updated"
    end
    redirect_to admin_item_category_custom_fields_path(@category)
  end

  def destroy
    custom_field_mapping = @custom_field.custom_field_mappings.find(params[:id])
    custom_field_mapping.destroy
    flash[:notice] = "Custom field mapping deleted successfully"
    redirect_to admin_item_category_custom_fields_path(@category)
  end

end
