class UpgradeOrdersLogic < ActiveRecord::Migration
  def change
    # Buyer model
    remove_column :buyers, :account_id
    remove_column :buyers, :first_name
    remove_column :buyers, :last_name
    add_column :buyers, :marketplace_id, :integer
    add_column :buyers, :name, :string
    add_column :buyers, :phone_number, :string

    # Order model
    remove_column :orders, :ship_to
    remove_column :orders, :total_price
    add_column :orders, :order_shipping_detail_id, :integer
    add_column :orders, :payment_status, :string
    add_column :orders, :paid_at, :datetime
    add_column :orders, :refunded_at, :datetime
    add_column :orders, :shipped, :boolean
    add_column :orders, :shipped_at, :datetime
    add_column :orders, :cancelled, :boolean
    add_column :orders, :cancelled_at, :datetime
    add_column :orders, :cancel_reason, :string
    add_column :orders, :notes, :text
    add_column :orders, :payment_method, :string
    add_column :orders, :create_timestamp, :datetime
    add_column :orders, :update_timestamp, :datetime
    add_column :orders, :grand_total, :decimal, :precision => 16, :scale => 4
    add_column :orders, :sub_total, :decimal, :precision => 16, :scale => 4
    add_column :orders, :discount, :decimal, :precision => 16, :scale => 4
    add_column :orders, :tax, :decimal, :precision => 16, :scale => 4

    # OrderListing model
    add_column :order_listings, :uid, :string
  end
end
