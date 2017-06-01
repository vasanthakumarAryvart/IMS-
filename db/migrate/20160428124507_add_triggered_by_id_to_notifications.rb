class AddTriggeredByIdToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :triggered_by_id, :integer
  end
end
