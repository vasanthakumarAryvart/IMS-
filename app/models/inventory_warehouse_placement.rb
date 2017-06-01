class InventoryWarehousePlacement < ActiveRecord::Base
  belongs_to :inventory_item, :inverse_of => :warehouse_placements
  belongs_to :warehouse_pin

  validates_presence_of :warehouse_pin, :quantity, :inventory_item
  validates_numericality_of :quantity, :greater_than_or_equal_to => 0

  after_save :delete_if_0_quantity

  def warehouse
    warehouse_pin.try(:warehouse)
  end

  private

  def delete_if_0_quantity
    self.delete if quantity == 0
  end
end
