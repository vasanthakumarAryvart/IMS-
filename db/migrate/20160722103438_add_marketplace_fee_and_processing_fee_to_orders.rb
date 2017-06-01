class AddMarketplaceFeeAndProcessingFeeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :marketplace_fee, :decimal, :precision => 10, :scale => 2
    add_column :orders, :processing_fee, :decimal, :precision => 10, :scale => 2
  end
end
