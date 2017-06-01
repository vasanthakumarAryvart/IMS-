class Inventory::Item < Inventory::ActiveModel
  self.table_name = 'item'

  belongs_to :category, :class_name => 'Inventory::Category'
  belongs_to :source, :class_name => 'Inventory::Login'
end
