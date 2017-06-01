class CreateMarketplaces < ActiveRecord::Migration
  def change
    create_table :marketplaces do |t|
      t.string :name
      t.string :url
      t.text :settings
      t.boolean :disabled

      t.timestamps
    end
    add_attachment :marketplaces, :image
  end
end
