class ListingImage < ActiveRecord::Base
  belongs_to :listing, :inverse_of => :images
  belongs_to :listing_template, :inverse_of => :images

  has_attached_file :image, :styles => { :preview => "400x300", :standard => '1600x1200' }
  #validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
  do_not_validate_attachment_file_type :image

  validate :requires_listing_or_template

  private

  def requires_listing_or_template
    unless (listing || listing_template) && !(listing && listing_template)
      errors.add :base, "Must specify either listing or listing template"
    end
  end
end
