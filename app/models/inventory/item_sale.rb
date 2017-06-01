class Inventory::ItemSale < Inventory::ActiveModel
  self.table_name = 'item_sale'

  belongs_to :sale, :class_name => 'Inventory::Sale'
  belongs_to :item, :class_name => 'Inventory::Item'
end
