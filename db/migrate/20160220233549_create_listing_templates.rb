class CreateListingTemplates < ActiveRecord::Migration
  def change
    create_table :listing_templates do |t|
      t.integer :item_category_id
      t.string :title
      t.string :make
      t.string :model
      t.text :description

      t.timestamps
    end
  end
end
