class ListingsController < ApplicationController
  before_filter {
    @top_menu_item = :listings
  }
  before_filter :require_listing!, :only => [:show, :edit, :update, :destroy, :unarchive, :cancel_pending]

  ATTRIBUTES_FOR_CREATE = [
      :item_category_id,
      :inventory_item_id,
      :cost,
      :publish_on,
      :shipping_preset_id,
      :listing_template_id,
      :data_fields_attributes => [
          :id,
          :custom_field_id,
          :marketplace_id,
          :value,
          :value => []
      ],
      :account_listings_attributes => [
          :id,
          :account_id,
          :publish,
          :pricing_type,
          :price,
          :min_price,
          :formula,
          :relative_pricing,
          :listing_type
      ],
      :warehouse_placements_attributes => [
          :id,
          :warehouse_pin_id,
          :quantity,
          :_destroy
      ]
  ]
  ATTRIBUTES_FOR_UPDATE = ATTRIBUTES_FOR_CREATE - [:item_category_id]

  def index
        @listings = Listing.all

    @filter = params[:filter] || {}
    # @listings = current_user.listings.active.order('created_at DESC').to_a
    @filter_item_types = [["Active", :active], ["Recently Added", :recent], ["Archived", :archived]]
    @filter_sort_options = [["Newest First", :new], ["Oldest First", :old], ["Alphabetically", :alpha], ["Popular First", :popular]]

    unless @filter.blank?
      @listings = current_user.listings.archived.order('created_at DESC').to_a if @filter[:item_type].try(:to_sym) == :archived

      @listings.select! { |l|
        l.account_listings.published.map(&:account).map(&:marketplace).map(&:name).include?(@filter[:marketplace])
      } unless @filter[:marketplace].blank?

      category = ItemCategory.find_by_id(@filter[:category]) unless @filter[:category].blank?
      @listings.select! { |l|
        ([category.id] + category.recursive_child_categories.map(&:id)).include?(l.item_category_id)
      } if category

      @listings.select! { |l|
        [l.title, l.item_category.title, l.description, l.make, l.model].join(' ').downcase.include?(@filter[:term].downcase)
      } unless @filter[:term].blank?

      case @filter[:sort]
        when 'old'
          @listings.sort_by! { |l| l.created_at }
        when 'alpha'
          @listings.sort_by! { |l| l.title }
        when 'popular'
          @listings.sort_by! { |l|
            -l.account_listings.map(&:order_items).map(&:count).compact.inject(&:+)
          }
        else # :new
          @listings.sort_by! { |l| -l.created_at.to_i }
      end
    end
    render :layout => false if @filter[:ajax]
  end

  def new
    @listing_template = ListingTemplate.find_by_id(params[:template_id])
    inventory_item = InventoryItem.find(params[:inventory_item_id]) unless params[:inventory_item_id].blank?
    @listing_template = inventory_item.listing_template if inventory_item
    @listing = current_user.listings.build(
        :item_category => @listing_template.try(:item_category) || inventory_item.try(:item_category) || ItemCategory.find(params[:item_category_id]),
        :listing_template => @listing_template || inventory_item.try(:listing_template),
        :inventory_item => inventory_item,
        :cost => inventory_item.try(:acquisition_cost)
    )
    marketplaces = current_user.enabled_accounts.map(&:marketplace)
    @listing.item_category.custom_fields.each { |field|
      next if field.hidden?
      if field.set_per_marketplace?
        marketplaces.each { |marketplace|
          mapping = field.custom_field_mapping_for(marketplace)
          next unless mapping
          next if mapping.marketplace_field_config[:for] && !mapping.marketplace_field_config[:for].map(&:to_s).include?('create')
          val = @listing_template.data_fields.find { |f| f.custom_field == field && (f.marketplace.blank? || f.marketplace == marketplace) }.try(:value) if @listing_template
          @listing.data_fields.build(:custom_field => field, :marketplace => marketplace, :value => val || mapping.marketplace_field_config[:default_value])
        }
      else
        val = @listing_template.data_fields.find { |f| f.custom_field == field }.try(:value) if @listing_template
        @listing.data_fields.build(:custom_field => field, :value => val)
      end
    }
    if @listing_template
      @listing.images = @listing_template.images
    elsif inventory_item
      @listing.data_fields.each { |df|
        if df.custom_field.make_field?
          df.value = inventory_item.make
        elsif df.custom_field.model_field?
          df.value = inventory_item.model
        elsif df.custom_field.description_field?
          df.value = inventory_item.notes
        elsif df.custom_field.title_field?
          df.value = inventory_item.title
        end
      }
    end
    current_user.accounts.each { |account|
      @listing.account_listings.build(:account => account)
    }
  end

  def edit
    if @listing.editable?
      marketplaces = current_user.enabled_accounts.map(&:marketplace)
      @listing.item_category.custom_fields.each { |field|
        next if field.hidden?
        if field.set_per_marketplace?
          marketplaces.each { |marketplace|
            mapping = field.custom_field_mapping_for(marketplace)
            next unless mapping
            next if @listing.data_fields.select { |df| df.marketplace == marketplace }.map(&:custom_field).include?(field)
            next if mapping.marketplace_field_config[:for] && !mapping.marketplace_field_config[:for].map(&:to_s).include?('update')
            @listing.data_fields.build(:custom_field => field, :marketplace => marketplace, :value => mapping.marketplace_field_config[:default_value])
          }
        else
          next if @listing.data_fields.map(&:custom_field).include?(field)
          @listing.data_fields.build(:custom_field => field)
        end
      }
      current_user.accounts.each { |account|
        @listing.account_listings.build(:account => account) unless @listing.account_listings.map(&:account).include?(account)
      }
    else
      flash[:alert] = "The listing is not editable now. Please wait for current operations to finish first"
      redirect_to listing_path(@listing)
    end
  end

  def show
  end

  def create
    @listing = current_user.listings.build(params[:listing].permit(ATTRIBUTES_FOR_CREATE))
    (params[:images] || {}).values.each_with_index { |img, i|
      @listing.images.build(:image => img, :sort_order => i)
    }
    if @listing.save
      flash[:notice] = "Listing created successfully"
      redirect_to listing_path(@listing)
    else
      flash.now[:alert] = "There was an error creating your listing"
      render 'new'
    end
  end

  def update
    if @listing.editable?
      @listing.images.each { |image|
        image.destroy unless params[:images].keys.map(&:to_i).include?(image.id)
      }
      i = 0
      (params[:images] || {}).each { |id, img|
        i += 1
        image = @listing.images.find_by_id(id)
        image.update_attribute(:sort_order, i) if image # update sort order anyway
        next if img.starts_with?('http') # didn't change? skip it!
        if image
          image.update_attributes(:image => img)
        else
          @listing.images.build(:image => img, :sort_order => i)
        end
      }
      if @listing.update_attributes(params[:listing].permit(ATTRIBUTES_FOR_UPDATE))
        flash[:notice] = "Listing updated successfully"
        redirect_to listing_path(@listing)
      else
        flash.now[:alert] = "There was an error updating your listing"
        render 'new'
      end
    else
      flash[:alert] = "The listing is not editable now. Please wait for current operations to finish first"
      redirect_to listing_path(@listing)
    end
  end

  def destroy
    if @listing.editable?
      if @listing.can_delete?
        if (@listing.destroy rescue false)
          flash[:notice] = "Listing removed"
        else
          flash[:alert] = "There was an error deleting your listing. Check if it has any orders"
        end
        redirect_to :listings
      else
        @listing.archive!
        flash[:notice] = "Listing unpublished from all marketplaces and moved to archive"
        redirect_to :listings
      end
    else
      flash[:error] = "Listing cannot be deleted while it has actions pending or running. Please try again later"
      redirect_to listing_path(@listing)
    end
  end

  def unarchive
    if @listing.archived?
      @listing.unarchive!
      flash[:notice] = "Listing unarchived successfully"
      redirect_to listing_path(@listing)
    else
      flash[:error] = "Listing was not archived"
      redirect_to listing_path(@listing)
    end
  end

  def cancel_pending
    if @listing.pending?
      @listing.cancel_pending!
      flash[:notice] = "Pending actions for the listing canceled"
      redirect_to listing_path(@listing)
    else
      flash[:error] = "Listing is not in pending state"
      redirect_to listing_path(@listing)
    end
  end

  def suggest_template
    render :json => ListingTemplate.where(:item_category_id => params[:item_category_id]).select { |t|
      t.title.downcase.include?(params[:term].downcase) unless params[:term].blank?
    }.map { |t|
      { :label => t.title, :value => t.id }
    }
  end

  def inventory
    @inventory_items = InventoryItem.all
    @filter = params[:filter] || {}
    @items = InventoryItem.active.order('id DESC')
    unless @filter.blank?
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

  private

  def require_listing!
    @listing = current_user.is_admin? ? Listing.find_by_id(params[:id]) : current_user.listings.find(params[:id])
  rescue
    flash[:alert] = "You don't have access to this listing"
    redirect_to root_url
  end
end
