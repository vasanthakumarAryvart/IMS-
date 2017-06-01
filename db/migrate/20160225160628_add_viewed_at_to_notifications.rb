class AddViewedAtToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :viewed_at, :datetime
    add_column :notifications, :user_id, :integer
  end
end
