module Integrations
  module Amazon
    module Orders

      # http://docs.developer.amazonservices.com/en_US/orders/2013-09-01/Orders_ListOrders.html
      def get_orders(date_from, date_to)
        return [] if date_from.blank? or date_to.blank?
        return [] if !date_from.is_a?(DateTime) or !date_to.is_a?(DateTime)
        return [] if date_from > date_to
        orders = @client_orders.list_orders(created_after: date_from.strftime('%Y-%m-%d'), created_before: date_to.strftime('%Y-%m-%d'))

        ((orders.parse['Orders'] || {})['Order'] || []).map do |order|
          {
              id: order['AmazonOrderId'],
              # Available options
              # Ex: PendingAvailability Pending Unshipped PartiallyShipped Shipped InvoiceUnconfirmed Canceled Unfulfillable
              # Unshipped and PartiallyShipped must be used together
              payment_status: case order['OrderStatus']
                                when 'Pending', 'PendingAvailability', 'Canceled'
                                  :new
                                when 'Unshipped', 'PartiallyShipped', 'Shipped'
                                  :paid
                              end,
              custom_status: order['OrderStatus'],
              created_at: DateTime.parse(order['PurchaseDate']),
              shipped: order['OrderStatus'] == 'Shipped',
              shipped_at: DateTime.parse(order['LatestShipDate']),
              cancelled: order['OrderStatus'] == 'Canceled',

              totals: {
                  grandtotal: order['OrderTotal'] ? order['OrderTotal']['Amount'].to_f : nil,
                  # subtotal:
                  # tax
                  # vat
                  # discount
              },
              items: order_items(order['AmazonOrderId']),
              buyer: {
                  id: order['BuyerEmail'],
                  name: order['BuyerName'],
                  email: order['BuyerEmail'],
                  # phone_number
              },
              shipping: {
                  name: order['ShippingAddress'] ? order['ShippingAddress']['Name'] : nil,
                  country: order['ShippingAddress'] ? order['ShippingAddress']['CountryCode'] : nil,
                  city: order['ShippingAddress'] ? order['ShippingAddress']['City'] : nil,
                  postal_code: order['ShippingAddress'] ? order['ShippingAddress']['PostalCode'] : nil,
                  address_line_1: order['ShippingAddress'] ? order['ShippingAddress']['AddressLine1'] : nil,
                  phone: order['ShippingAddress'] ? order['ShippingAddress']['Phone'] : nil,
                  state: order['ShippingAddress'] ? order['ShippingAddress']['StateOrRegion'] : nil,
                  # price
                  # carrier
                  # tracking_code
                  # tracking_url
                  # notes
                  # available_carriers
              },

              payment_method: order['PaymentMethod'],
              last_update_at: DateTime.parse(order['LastUpdateDate']),
              # cancelled_at
              # cancel_reason
              # notes
              # paid_at
          }
        end
      end

      # def update_order(order)
      #   xml = Builder::XmlMarkup.new
      #   xml.instruct! :xml, version: '1.0'
      #
      #   if order[:status] == 'cancelled'
      #     xml.AmazonEnvelope do |envelope|
      #       envelope.Header do |header|
      #         header.DocumentVersion '1.01'
      #         header.MerchantIdentifier @state[:merchant_id]
      #       end
      #       envelope.MessageType 'OrderAcknowledgement'
      #       envelope.Message do |m|
      #         m.MessageID '1'
      #         m.OrderAcknowledgement do |oa|
      #           oa.AmazonOrderID order[:order_id]
      #           oa.StatusCode 'Failure'
      #           # oa.Item do |item|
      #           #   item.AmazonOrderItemCode ''
      #           #   item.CancelReason order['cancel_reason']
      #           # end
      #         end
      #       end
      #     end
      #     result = @client_feeds.submit_feed(xml.target!, 'OrderAcknowledgement', {})
      #     # result = result.parse['FeedSubmissionInfo']['FeedSubmissionId'] rescue nil
      #   else
      #     xml.AmazonEnvelope do |envelope|
      #       envelope.Header do |header|
      #         header.DocumentVersion '1.01'
      #         header.MerchantIdentifier @state[:merchant_id]
      #       end
      #       envelope.MessageType 'OrderFulfillment'
      #       envelope.Message do |m|
      #         m.MessageID '1'
      #         m.OrderFulfillment do |of|
      #           of.AmazonOrderID order[:order_id]
      #           of.FulfillmentDate DateTime.current.to_s
      #           of.FulfillmentData do |fd|
      #             fd.CarrierName order[:shipping_carrier_id]
      #             fd.ShippingMethod 'Standard'
      #             fd.ShipperTrackingNumber order[:tracking_code]
      #           end
      #           # of.Item do |item|
      #           #   item.AmazonOrderItemCode ''
      #           #   item.Quantity ''
      #           # end
      #         end
      #       end
      #     end
      #     result = @client_feeds.submit_feed(xml.target!, '_POST_ORDER_FULFILLMENT_DATA_', {})
      #     # result = result.parse['FeedSubmissionInfo']['FeedSubmissionId'] rescue nil
      #   end
      # end

      # http://docs.developer.amazonservices.com/en_US/orders/2013-09-01/Orders_ListOrderItems.html
      def order_items(amazon_order_id)
        items_data = @client_orders.list_order_items(amazon_order_id).parse['OrderItems']
        items = items_data['OrderItem'].is_a?(Hash) ? [items_data['OrderItem']] : items_data['OrderItem']
        items.map do |item|
          {
              item_id: item.try(:[], 'OrderItemId') || item.try(:[], 'SellerSKU') || item.try(:[], 'ASIN'),
              quantity: item['QuantityOrdered'],
              price: item['ItemPrice'] && ((item['QuantityOrdered'] || 0).to_i > 0) ? item['ItemPrice']['Amount'].to_f / item['QuantityOrdered'].to_i : nil,
          }
        end
      end
    end
  end
end