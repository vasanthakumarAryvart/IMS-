namespace :orders do
  task :refresh => :environment do
    User.all.each { |user|
      user.enqueue_refresh_orders!
    }
  end

end