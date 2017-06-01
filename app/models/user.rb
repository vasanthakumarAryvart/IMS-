class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :accounts
  has_many :warehouses
  has_many :shipping_presets
  has_many :listings
  has_many :user_notifications, :class_name => 'Notification', :foreign_key => 'user_id'
  has_many :accounts_notifications, :through => :accounts, :source => :notifications
  has_many :orders, :through => :accounts

  validates_presence_of :first_name, :last_name

  has_attached_file :image, styles: { thumb: ["64x64#", :png], medium: ["256x256#", :png], large: ["512x512#", :png] }, :default_url => 'default-user-icon.png'
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  EDITABLE_FIELDS = [:first_name, :last_name, :company_name, :phone_number, :image]

  after_create :create_default_accounts

  scope :admins, -> { where(:is_admin => true) }

  def enabled_accounts
    accounts.reject { |a| (a.integration.logged_in? rescue :not_implemented) == :not_implemented }
  end

  def configured_accounts
    accounts.select(&:configured?)
  end

  def full_name
    [first_name, last_name].reject(&:blank?).join(' ')
  end

  def full_name_with_id
    "#{full_name} ##{id}"
  end

  def notifications
    (user_notifications + accounts_notifications).sort_by(&:created_at).reverse
  end

  def make_admin!
    update_attribute(:is_admin, true)
  end

  def revoke_admin!
    update_attribute(:is_admin, false)
  end

  def block!
    update_attribute(:blocked_at, DateTime.now)
  end

  def unblock!
    update_attribute(:blocked_at, nil)
  end

  def blocked?
    !blocked_at.blank?
  end

  def integration_for(marketplace)
    accounts.find { |a| a.marketplace == marketplace }.integration
  end

  def enqueue_refresh_orders!
    self.update_attributes(:orders_refresh_started_at => DateTime.now, :orders_refresh_completed_at => nil)
    User.delay.refresh_orders(self.id)
  end

  def self.refresh_orders(user_id)
    user = User.find(user_id)
    user.update_attributes(:orders_refresh_started_at => DateTime.now, :orders_refresh_completed_at => nil)
    user.accounts.each {|account|
      next if account.state.blank?
      next unless account.integration.logged_in? rescue false
      Order.refresh_for_account(account.id)
    }
  ensure
    user.update_attribute(:orders_refresh_completed_at, DateTime.now)
  end

  def refreshing_orders?
    orders_refresh_started_at && !orders_refresh_completed_at
  end

  private

  def create_default_accounts
    Marketplace.all.each { |marketplace|
      Account.create(:user => self, :title => marketplace.name, :marketplace => marketplace)
    }
  end
end
