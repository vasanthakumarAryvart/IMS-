class AddRealPriceToOrderShippingDetails < ActiveRecord::Migration
  def change
    add_column :order_shipping_details, :real_price, :decimal, :precision => 16, :scale => 2
  end
end
