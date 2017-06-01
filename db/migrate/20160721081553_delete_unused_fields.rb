class DeleteUnusedFields < ActiveRecord::Migration
  def change
    remove_columns :listings, :make, :model, :title, :description
    remove_columns :listing_templates, :make, :model, :title, :description
  end
end
