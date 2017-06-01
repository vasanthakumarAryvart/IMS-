class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :account
  belongs_to :item, :polymorphic => true
  belongs_to :triggered_by, :class_name => 'User'

  TYPES = {
      :user => %w{account_connected account_disconnected},
      :account => %w{new_order listing_create_failed listing_update_failed listing_delete_failed},
      :system => %w{new_user admin_added admin_removed}
  }

  validates_presence_of :notification_type, :user
  validates_inclusion_of :notification_type, :in => TYPES[:user], :if => Proc.new { |n| n.user && !n.system? && !n.account }
  validates_inclusion_of :notification_type, :in => TYPES[:account], :if => Proc.new { |n| n.account }
  validates_inclusion_of :notification_type, :in => TYPES[:system], :if => Proc.new { |n| n.system? }

  scope :system, -> { where(:system => true) }

  def self.add_for_user(user, type, item = nil, triggered_by = nil)
    n = Notification.create!({
                                 :user => user,
                                 :notification_type => type.to_s,
                                 :item => item,
                                 :triggered_by => triggered_by
                             })
    Mailer.notification(n).deliver!
  end

  def self.add_for_account(account, type, item = nil, triggered_by = nil)
    n = Notification.create!({
                                 :user => account.user,
                                 :account => account,
                                 :notification_type => type.to_s,
                                 :item => item,
                                 :triggered_by => triggered_by
                             })
    Mailer.notification(n).deliver!
  end

  def self.add_for_system(type, item = nil, triggered_by = nil)
    User.admins.each { |admin|
      n = Notification.create!({
                                   :user => admin,
                                   :notification_type => type.to_s,
                                   :item => item,
                                   :system => true,
                                   :triggered_by => triggered_by
                               })
      Mailer.notification(n).deliver!
    }
  end

  def self.add_global(type, item = nil, triggered_by = nil)
    User.all.each { |user|
      n = Notification.create!({
                                   :user => user,
                                   :notification_type => type.to_s,
                                   :item => item,
                                   :triggered_by => triggered_by
                               })
      Mailer.notification(n).deliver!
    }
  end

  def self.view!(type, user_or_account, item = nil)
    if user_or_account.is_a?(User)
      Notification.where(:user => user_or_account, :notification_type => type, :item => item).map(&:view!)
    elsif user_or_account.is_a?(Account)
      Notification.where(:account => user_or_account, :notification_type => type, :item => item).map(&:view!)
    else
      raise 'Invalid behaviour'
    end
  end

  def viewed?
    !!viewed_at
  end

  def view!
    update_attribute(:viewed_at, DateTime.now)
  end

  def link
    case notification_type.to_s
      # todo: implement
      when ''
    end
  end

  def title
    self[:title] ||
        case notification_type.to_s
          # todo: implement
          when ''
        end
  end

  def content
    self[:content] ||
        case notification_type.to_s
          # todo: implement
          when ''
        end
  end
end
