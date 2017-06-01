class OrderShippingDetail < ActiveRecord::Base
  has_one :order
  belongs_to :buyer

  serialize :available_carriers
end
