module Inventory
  class ActiveModel < ActiveRecord::Base
    self.abstract_class = true

    #establish_connection "inventory_#{Rails.env}".to_sym
  end
end
