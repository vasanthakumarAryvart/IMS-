class UpdateNotificationFields < ActiveRecord::Migration
  def change
    rename_column :notifications, :type, :notification_type
    add_column :notifications, :item_type, :string
    add_column :notifications, :item_id, :integer
    add_column :notifications, :global, :boolean
    add_column :notifications, :system, :boolean
    remove_column :notifications, :url
  end
end
