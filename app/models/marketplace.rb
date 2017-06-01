class Marketplace < ActiveRecord::Base
  has_many :accounts
  has_many :buyers

  serialize :settings

  has_attached_file :image
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
  validates_uniqueness_of :name

  scope :with_api, -> { where(:has_api => true) }

  def ebay?
    name.downcase == 'ebay'
  end

  def amazon?
    name.downcase == 'amazon'
  end

  def shopify?
    name.downcase == 'shopify'
  end

  def etsy?
    name.downcase == 'etsy'
  end

  def self.direct
    Marketplace.where(:name => 'Direct').first
  end

  def icon_url
    "marketplaces/#{name.downcase}.png"
  end
end
