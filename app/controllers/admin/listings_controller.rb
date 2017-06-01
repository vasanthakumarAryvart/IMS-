class Admin::ListingsController < Admin::AdminController
  before_filter {
    @top_menu_item = :listings
  }

  def index
    @filter = params[:filter] || {}
    @listings = Listing.active.order('created_at DESC')
    @filter_item_types = [["Active", :active], ["Recently Added", :recent], ["Archived", :archived]]
    @filter_sort_options = [["Newest First", :new], ["Oldest First", :old], ["Alphabetically", :alpha], ["Popular First", :popular]]

    unless @filter.blank?
      # user
      @listings = @listings.where(:user_id => @filter[:user]) unless @filter[:user].blank?

      @listings = @listings.archived if @filter[:item_type].try(:to_sym) == :archived

      @listings = @listings.to_a

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
    render :layout => false unless @filter.empty?
  end

end
