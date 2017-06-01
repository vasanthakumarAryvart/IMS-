class Buyer < ActiveRecord::Base
  has_many :orders
  belongs_to :marketplace
  has_many :order_shipping_details

  validates_presence_of :uid#, :name

  before_validation {
    self.uid = generate_uid if new_record? && self.uid.blank?
  }

  def generate_uid
    Digest::MD5.hexdigest([marketplace_id, name, email, phone_number].join)
  end
end
