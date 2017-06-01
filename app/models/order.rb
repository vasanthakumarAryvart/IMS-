class Order < ActiveRecord::Base
  belongs_to :account
  belongs_to :buyer
  belongs_to :order_shipping_detail
  has_many :order_items, :dependent => :destroy

  validates_presence_of :account, :uid
  validates_numericality_of :grand_total, :greater_than_or_equal_to => 0, :allow_blank => true

  accepts_nested_attributes_for :order_shipping_detail
  accepts_nested_attributes_for :buyer

  STATUSES = %w{awaiting_payment awaiting_shipping shipped cancelled rejected}
  PAYMENT_STATUSES = %w{new paid refunded}

  def create_timestamp
    self[:create_timestamp] || created_at
  end

  def update_timestamp
    self[:update_timestamp] || updated_at
  end

  def refunded?
    payment_status.to_sym == :refunded
  end

  def user
    account.user
  end

  def status
    return :shipped if shipped?
    return :cancelled if cancelled?
    return :rejected if refunded?
    return :awaiting_payment if payment_status.to_sym == :new
    return :awaiting_shipping if payment_status.to_sym == :paid
  end

  def self.refresh_for_account(account_id, date_from = 7.days.ago.to_date, date_to = DateTime.now.to_date)
    account = Account.find_by(:id => account_id)
    return false unless account.integration.logged_in?
    orders = account.integration.get_orders(date_from.to_datetime, date_to.to_datetime)
    orders.each { |order|
      process_external_order account, order.with_indifferent_access
    }
  end

  def acquisition_cost
    order_items.map(&:acquisition_cost).inject(&:+) || 0
  end

  def profit_share_deductions
    order_items.map {|oi|
      if ii = oi.inventory_item
        (oi.total - oi.acquisition_cost) * ii.cached_profit_share_percent / 100.0
      end
    }.compact.inject(&:+) || 0
  end

  def net_profit
    (grand_total || 0) - (marketplace_fee || 0) - (processing_fee || 0) - (order_shipping_detail.try(:real_price) || 0) - acquisition_cost - profit_share_deductions
  end

  private

  def self.process_external_order(account, order)
    if order_entry = account.orders.find_by(:uid => order[:id])
      # update order
      Order.transaction do
        # update/create Buyer record
        buyer = order_entry.buyer
        if (order[:buyer][:id] rescue false)
          buyer = account.marketplace.buyers.find_or_initialize_by(:uid => order[:buyer][:id])
          buyer.update_attributes!(order[:buyer].slice(:name, :email, :phone_number).select { |k, v| !v.blank? })
        end
        # update OrderShippingDetail record
        unless order[:shipping].blank?
          if shipping_detail = order_entry.order_shipping_detail
            order_entry.order_shipping_detail.update_attributes!(order[:shipping].merge(:buyer_id => buyer.try(:id)))
          else
            shipping_detail = OrderShippingDetail.create!(order[:shipping].merge(:buyer_id => buyer.try(:id)))
          end
        end
        # update Order record
        order_entry.update_attributes({
                                          :buyer_id => buyer.try(:id),
                                          :order_shipping_detail_id => shipping_detail.try(:id),
                                          :update_timestamp => order[:last_update_at]
                                      }
                                          .merge({ :grand_total => order[:totals][:grandtotal],
                                                   :sub_total => order[:totals][:subtotal],
                                                   :discount => order[:totals][:discount],
                                                   :tax => order[:totals][:tax] }.select { |k, v| !v.blank? })
                                          .merge(order.slice(:payment_status,
                                                             :paid_at, :refunded_at,
                                                             :shipped, :shipped_at,
                                                             :cancelled, :cancelled_at, :cancel_reason,
                                                             :notes, :payment_method)))
        # TODO: update OrderListing records?
      end
    else
      # create order
      Order.transaction do
        # create/update Buyer record
        if (order[:buyer][:id] rescue false)
          buyer = account.marketplace.buyers.find_or_initialize_by(:uid => order[:buyer][:id])
          buyer.update_attributes!(order[:buyer].slice(:name, :email, :phone_number).select { |k, v| !v.blank? })
        end
        # create OrderShippingDetail record
        shipping_detail = OrderShippingDetail.create!(order[:shipping].merge(:buyer_id => buyer.try(:id))) unless order[:shipping].blank?
        # create Order record
        order_entry = account.orders.create!({
                                                 :buyer_id => buyer.try(:id),
                                                 :order_shipping_detail_id => shipping_detail.try(:id),
                                                 :uid => order[:id],
                                                 :create_timestamp => order[:created_at],
                                                 :update_timestamp => order[:last_update_at],
                                                 :grand_total => order[:totals][:grandtotal],
                                                 :sub_total => order[:totals][:subtotal],
                                                 :discount => order[:totals][:discount],
                                                 :tax => order[:totals][:tax],
                                             }.merge(order.slice(:payment_status,
                                                                 :paid_at, :refunded_at,
                                                                 :shipped, :shipped_at,
                                                                 :cancelled, :cancelled_at, :cancel_reason,
                                                                 :notes, :payment_method)))
        # create OrderListing records
        order[:items].each { |item|
          next if item[:item_id].blank? || (item[:quantity].try(:to_i) || 0) == 0
          account_listing = account.account_listings.find_by(:uid => item[:item_id])
          if (item[:price].try(:to_i) || 0) <= 0
            if account_listing
              item[:price] = account_listing.price
            else
              next
            end
          end
          order_entry.order_items.create!(:uid => item[:item_id], :quantity => item[:quantity], :item_price => item[:price], :account_listing_id => account_listing.try(:id))
        }
      end
    end
  end
end
