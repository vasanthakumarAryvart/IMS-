class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :type
      t.integer :account_id
      t.string :title
      t.text :content
      t.string :url

      t.timestamps
    end
  end
end
