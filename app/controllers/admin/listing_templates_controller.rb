class Admin::ListingTemplatesController < Admin::AdminController
  before_filter {
    @top_menu_item = :listings
  }
  before_filter :require_listing_template!, :only => [:show, :edit, :update, :destroy]

  ATTRIBUTES_FOR_CREATE = [
      :item_category_id,
      :inventory_item_id,
      :data_fields_attributes => [
          :id,
          :custom_field_id,
          :marketplace_id,
          :value,
          :value => []
      ]
  ]
  ATTRIBUTES_FOR_UPDATE = ATTRIBUTES_FOR_CREATE

  def index
    @filter = params[:filter] || {}
    @listing_templates = ListingTemplate.order('created_at DESC').to_a
    @filter_item_types = [["All", :all], ["Recent", :recent], ["Bestsellers", :bestsellers]]
    @filter_sort_options = [["Newest First", :new], ["Oldest First", :old], ["Alphabetically", :alpha], ["Popular First", :popular]]
    unless @filter.blank?
      category = ItemCategory.find_by_id(@filter[:category]) unless @filter[:category].blank?
      @listing_templates.select! { |l|
        ([category.id] + category.recursive_child_categories.map(&:id)).include?(l.item_category_id)
      } if category

      @listing_templates.select! { |l|
        [l.title, l.item_category.title, l.description, l.make, l.model].join(' ').downcase.include?(@filter[:term].downcase)
      } unless @filter[:term].blank?

      case @filter[:sort]
        when 'old'
          @listing_templates.sort_by! { |l| l.created_at }
        when 'alpha'
          @listing_templates.sort_by! { |l| l.title }
        when 'popular'
          @listing_templates.sort_by! { |l|
            -l.listings.count
          }
        else # :new
          @listing_templates.sort_by! { |l| -l.created_at.to_i }
      end
    end
    render :layout => false if @filter[:ajax]
  end

  def new
    inventory_item = InventoryItem.find(params[:inventory_item_id]) unless params[:inventory_item_id].blank?
    @listing_template = ListingTemplate.new(
        :item_category => inventory_item.try(:item_category) || ItemCategory.find(params[:item_category_id]),
        :inventory_item => inventory_item
    )

    marketplaces = Marketplace.with_api
    @listing_template.item_category.custom_fields.each { |field|
      next if field.hidden? || field.not_for_template?
      if field.set_per_marketplace?
        marketplaces.each { |marketplace|
          mapping = field.custom_field_mapping_for(marketplace)
          next unless mapping
          next if mapping.marketplace_field_config[:for] && !mapping.marketplace_field_config[:for].map(&:to_s).include?('create')
          @listing_template.data_fields.build(:custom_field => field, :marketplace => marketplace, :value => mapping.marketplace_field_config[:default_value])
        }
      else
        @listing_template.data_fields.build(:custom_field => field)
      end
    }
    @listing_template.data_fields.each { |df|
      if df.custom_field.make_field?
        df.value = inventory_item.make
      elsif df.custom_field.model_field?
        df.value = inventory_item.model
      elsif df.custom_field.description_field?
        df.value = inventory_item.notes
      elsif df.custom_field.title_field?
        df.value = inventory_item.title
      end
    } if inventory_item
  end

  def edit
    @listing_template.item_category.custom_fields.each { |field|
      next if field.hidden? || field.not_for_template?
      next if @listing_template.data_fields.map(&:custom_field).include?(field)
      if field.set_per_marketplace?
        current_user.enabled_accounts.map(&:marketplace).each { |marketplace|
          mapping = field.custom_field_mapping_for(marketplace)
          next unless mapping
          next if mapping.marketplace_field_config[:for] && !mapping.marketplace_field_config[:for].map(&:to_s).include?('create')
          @listing_template.data_fields.build(:custom_field => field, :marketplace => marketplace, :value => mapping.marketplace_field_config[:default_value])
        }
      else
        @listing_template.data_fields.build(:custom_field => field)
      end
    }
  end

  def show
  end

  def create
    @listing_template = ListingTemplate.new(params[:listing_template].permit(ATTRIBUTES_FOR_CREATE))
    (params[:images] || {}).values.each_with_index { |img, i|
      @listing_template.images.build(:image => img, :sort_order => i)
    }
    if @listing_template.save
      flash[:notice] = "Listing template created successfully"
      redirect_to admin_listing_template_path(@listing_template)
    else
      flash.now[:alert] = "There was an error creating listing template"
      render 'new'
    end
  end

  def update
    @listing_template.images.each { |image|
      image.destroy unless params[:images].keys.map(&:to_i).include?(image.id)
    }
    i = 0
    (params[:images] || {}).each { |id, img|
      i += 1
      image = @listing_template.images.find_by_id(id)
      image.update_attribute(:sort_order, i) if image # update sort order anyway
      next if img.starts_with?('http') # didn't change? skip it!
      if image
        image.update_attributes(:image => img)
      else
        @listing_template.images.build(:image => img)
      end
    }
    if @listing_template.update_attributes(params[:listing_template].permit(ATTRIBUTES_FOR_UPDATE))
      flash[:notice] = "Listing template updated successfully"
      redirect_to admin_listing_template_path(@listing_template)
    else
      flash.now[:alert] = "There was an error updating listing template"
      render 'new'
    end
  end

  def destroy
    @listing_template.destroy
    flash[:notice] = "Listing template removed"
    redirect_to :admin_listing_templates
  end

  private

  def require_listing_template!
    @listing_template = ListingTemplate.find(params[:id])
  rescue
    flash[:alert] = "Listing template not found"
    redirect_to root_url
  end
end
