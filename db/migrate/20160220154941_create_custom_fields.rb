class CreateCustomFields < ActiveRecord::Migration
  def change
    create_table :custom_fields do |t|
      t.string :name
      t.string :type
      t.integer :item_category_id
      t.boolean :not_for_template
      t.boolean :set_per_marketplace

      t.timestamps
    end
  end
end
