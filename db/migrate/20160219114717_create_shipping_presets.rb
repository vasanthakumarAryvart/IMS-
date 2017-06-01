class CreateShippingPresets < ActiveRecord::Migration
  def change
    create_table :shipping_presets do |t|
      t.string :title
      t.integer :user_id
      t.string :provider
      t.decimal :price, :precision => 16, :scale => 4
      t.text :description
      t.text :countries

      t.timestamps
    end
  end
end
