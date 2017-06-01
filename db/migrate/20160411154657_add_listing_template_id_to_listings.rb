class AddListingTemplateIdToListings < ActiveRecord::Migration
  def change
    add_column :listings, :listing_template_id, :integer
  end
end
