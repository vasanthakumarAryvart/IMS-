class Admin::CustomFieldsController < Admin::AdminController
  before_filter {
    @top_menu_item = :categories
  }
  before_filter {
    @category = ItemCategory.includes(:custom_fields, :marketplace_category_mappings).where(:id => params[:item_category_id]).first
  }

  EDITABLE_ATTRIBUTES = [:name, :hidden, :not_for_template, :set_per_marketplace, :hint, :required, :field_type, :field_subtype, :field_options, :field_options => []]

  def index
    @category.ensure_default_fields!
    @custom_fields = @category.custom_fields.order(:sort_order)
    # retrieve missing mappings per marketplace
    @missing_fields_per_marketplace = {}
    @category.marketplace_category_mappings.each { |mapping|
      fields = current_user.integration_for(mapping.marketplace).category_fields(mapping.marketplace_category) rescue nil
      next unless fields
      @missing_fields_per_marketplace[mapping.marketplace] = {}
      @missing_fields_per_marketplace[mapping.marketplace][:required] = fields.select { |f|
        f[:required] && !mapping.custom_field_mappings.map(&:marketplace_field).include?(f[:name])
      }
      @missing_fields_per_marketplace[mapping.marketplace][:optional] = fields.select { |f|
        !f[:required] && !mapping.custom_field_mappings.map(&:marketplace_field).include?(f[:name])
      }
    }
  end

  def new
    @custom_field = @category.custom_fields.build
    render :layout => false
  end

  def edit
    @custom_field = @category.custom_fields.find(params[:id])
    render :layout => false
  end

  def create
    if params[:custom_field]
      custom_field = @category.custom_fields.build(params[:custom_field].permit(EDITABLE_ATTRIBUTES))
      if custom_field.save
        flash[:notice] = "Custom field created successfully"
      else
        flash[:error] = "Custom field could not be created"
      end
    elsif field_config = JSON.parse(params[:mapping_field_config]).with_indifferent_access rescue nil
      custom_field = @category.custom_fields.build(
          :name => (field_config[:label] || field_config[:name]).humanize.split(' ').map(&:capitalize).join(' '),
          :set_per_marketplace => true
      )
      if custom_field.save
        custom_field.custom_field_mappings.create!(
            :marketplace_category_mapping_id => custom_field.item_category.marketplace_category_mapping_for(Marketplace.find(params[:marketplace_id])).id,
            :marketplace_field => field_config[:name],
            :marketplace_field_config => field_config,
            :required => !!field_config[:required]
        )
        flash[:notice] = "Custom field with mapping created successfully"
      else
        flash[:error] = "Custom field could not be created"
      end
    else
      flash[:error] = "Invalid action"
    end
    redirect_to admin_item_category_custom_fields_path(@category)
  end

  def update
    custom_field = @category.custom_fields.find(params[:id])
    if custom_field.update_attributes(params[:custom_field].permit(EDITABLE_ATTRIBUTES))
      flash[:notice] = "Custom field updated successfully"
    else
      flash[:error] = "Custom field could not be updated"
    end
    redirect_to admin_item_category_custom_fields_path(@category)
  end

  def destroy
    custom_field = @category.custom_fields.find(params[:id])
    if custom_field.can_delete?
      custom_field.destroy
      flash[:notice] = "Custom field deleted successfully"
    else
      flash[:error] = "Cannot delete this custom field - it is used by some listings or listing templates. Unassign them in order to delete"
    end
    redirect_to admin_item_category_custom_fields_path(@category)
  end

  def reorder
    custom_fields = (params[:ids] || []).map { |id|
      @category.custom_fields.find_by_id(id)
    }
    custom_fields.each_with_index { |field, i|
      field.update_attribute(:sort_order, i)
    }
    render :text => 'OK'
  end
end
