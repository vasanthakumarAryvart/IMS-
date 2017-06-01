class CreateSaleEvents < ActiveRecord::Migration
  def change
    create_table :sale_events do |t|
      t.integer :account_id
      t.integer :item_category_id
      t.string :start_date
      t.string :end_date
      t.decimal :discount_percent, :precision => 16, :scale => 4

      t.timestamps
    end
  end
end
