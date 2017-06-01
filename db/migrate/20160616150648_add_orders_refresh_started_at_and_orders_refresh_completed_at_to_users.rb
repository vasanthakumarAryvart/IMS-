class AddOrdersRefreshStartedAtAndOrdersRefreshCompletedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :orders_refresh_started_at, :datetime
    add_column :users, :orders_refresh_completed_at, :datetime
  end
end
