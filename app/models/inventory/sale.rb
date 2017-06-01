class Inventory::Sale < Inventory::ActiveModel
  self.table_name = 'sale'

  has_many :item_sales, :class_name => 'Inventory::ItemSale'
  belongs_to :rep, :class_name => 'Inventory::Login'
  belongs_to :market, :class_name => 'Inventory::Marketplace'

  def buyer_uid
    Digest::MD5.hexdigest([market_id, buyer_name, buyer_email, buyer_phone].join)
  end

  def buyer_defined?
    !buyer_name.blank?
  end
end
