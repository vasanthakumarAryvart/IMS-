class ListingDataField < ActiveRecord::Base
  belongs_to :listing, :inverse_of => :data_fields
  belongs_to :listing_template, :inverse_of => :data_fields
  belongs_to :custom_field
  belongs_to :marketplace

  validates_presence_of :custom_field
  validate :requires_listing_or_template
  validates_presence_of :marketplace, :if => ->(field) { field.custom_field.set_per_marketplace? }

  serialize :value

  private

  def requires_listing_or_template
    unless (listing || listing_template) && !(listing && listing_template)
      errors.add :base, "Must specify either listing or listing template"
    end
  end
end
