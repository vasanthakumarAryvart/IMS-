class Warehouse < ActiveRecord::Base
  belongs_to :user
  has_many :warehouse_pins

  has_attached_file :floor_plan
  validates_attachment_content_type :floor_plan, content_type: /\Aimage\/.*\Z/

  validates_presence_of :user, :title, :address

  after_save :check_if_floor_plan_changed

  def listings
    warehouse_pins.map(&:listing_placements).flatten.uniq.map(&:listing).uniq
  end

  def can_delete?
    self.listings.empty?
  end

  def check_if_floor_plan_changed
    self.warehouse_pins.each { |pin| pin.update_attribute(:location_on_plan, nil) } if self.floor_plan_updated_at_changed?
  end

  private :check_if_floor_plan_changed
end
