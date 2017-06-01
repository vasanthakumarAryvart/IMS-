class CreateListingImages < ActiveRecord::Migration
  def change
    create_table :listing_images do |t|
      t.integer :listing_id
      t.string :title
      t.integer :sort_order

      t.timestamps null: false
    end
    add_attachment :listing_images, :image
  end
end
