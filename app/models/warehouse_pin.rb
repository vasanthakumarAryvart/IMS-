class WarehousePin < ActiveRecord::Base
  belongs_to :warehouse
  has_many :listing_placements, :class_name => 'ListingWarehousePlacement'

  validates_presence_of :warehouse, :title

  serialize :location_on_plan

  def location_on_plan
    if self[:location_on_plan]
      {
          :x => self[:location_on_plan][:x].try(:to_f),
          :y => self[:location_on_plan][:y].try(:to_f),
          :width => self[:location_on_plan][:width].try(:to_f)
      }
    end
  end

  def can_delete?
    self.listing_placements.empty?
  end
end
