class AddBuyerIdToOrderShippingDetails < ActiveRecord::Migration
  def change
    add_column :order_shipping_details, :buyer_id, :integer
  end
end
