class AddManualToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :manual, :boolean
  end
end
