class AddListingTemplateIdToListingImages < ActiveRecord::Migration
  def change
    add_column :listing_images, :listing_template_id, :integer
  end
end
