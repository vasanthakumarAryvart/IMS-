class CreateListingDataFields < ActiveRecord::Migration
  def change
    create_table :listing_data_fields do |t|
      t.integer :listing_id
      t.integer :listing_template_id
      t.integer :custom_field_id
      t.text :value

      t.timestamps
    end
  end
end
