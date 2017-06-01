class Inventory::Login < Inventory::ActiveModel
  self.table_name = 'login'

  def first_name
    name.split(' ').first
  end

  def last_name
    name.split(' ')[1..-1].join(' ')
  end
end
