class SaleEvent < ActiveRecord::Base
  belongs_to :account
  belongs_to :item_category

  validates_presence_of :account, :item_category
  validates_numericality_of :discount_percent, :greater_than => 0

  after_save {
    SaleEvent.setup_sale_event(self)
  }
  after_destroy {
    SaleEvent.setup_sale_events(self.account_id)
  }

  def self.setup_sale_events(account_id = nil)
    account = Account.find(account_id) if account_id
    if account
      account.account_listings.map(&:update_discount_price!)
    else
      SaleEvent.all.each { |event|
        setup_sale_event(event)
      }
    end
  end

  def self.setup_sale_event(event)
    event.account_listings.each { |account_listing|
      account_listing.update_discount_price!
    }
  end

  def account_listings
    account.account_listings.joins(:listing => :item_category).where('item_categories.id = ?', item_category.id)
  end
end
