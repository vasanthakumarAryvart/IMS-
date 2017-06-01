class ItemSource < ActiveRecord::Base
  validates_presence_of :name, :profit_share_percent
  validates_numericality_of :profit_share_percent, :greater_than_or_equal_to => 0

  has_many :inventory_items, :dependent => :nullify
end
