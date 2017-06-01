require 'bundler/capistrano'
require "rvm/capistrano"

set :scm, 'git'
set :application, "clarabyte"
set :repository, "git@bitbucket.org:neolancer/clarabyte.git"
set :deploy_via, :remote_cache
set :ssh_options, { :forward_agent => true }

set :rvm_type, :system
set :rvm_ruby_string, 'ruby-2.1.0'

# cron jobs
require "whenever/capistrano"
set :whenever_command, "bundle exec whenever"
#set :whenever_environment, defer { stage }
set :whenever_identifier, defer { "#{application}_#{stage}" }

# Server
#set :user, "nginx"
default_run_options[:pty] = true
set :use_sudo, false
set :keep_releases, 20

task :staging do
  set :user, "root"
  set :rails_env, :staging
  set :rvm_ruby_string, 'ruby-2.1.0'
  set :domain, 'clarabyte-dev.synnergia.com'
  set :whenever_identifier, defer { "#{application}-staging" }
  server "clarabyte-dev.synnergia.com", :app, :web, :db, :primary => true
  set :deploy_to, "/home/data/www/synnergia/clarabyte"
end

task :production do
  set :rvm_type, :user
  set :rails_env, :production
  set :rvm_ruby_string, 'ruby-2.1.0'
  set :domain, 'clarabyte.com'
  set :whenever_identifier, defer { "#{application}-production" }
  server "clarabyte.com", :app, :web, :db, :primary => true
  set :deploy_to, "/data/www/clarabyte/production"
end

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# migrations
after 'deploy:link_config', 'deploy:migrate'

after 'deploy:update_code', 'deploy:link_config'

namespace :deploy do

  desc 'Zero-downtime restart of Unicorn'
  task :restart, except: {no_release: true} do
    run "#{try_sudo} chown -R nginx:nginx #{current_path}/../"
    run "kill -s USR2 `cat #{shared_path}/pids/unicorn.pid`"
    run "touch #{File.join(current_path, 'tmp', 'restart.txt')}"
    # sidekiq
    run "cd #{current_path} ; RAILS_ENV=#{rails_env} bundle exec sidekiqctl stop #{shared_path}/pids/sidekiq.pid"
    run "cd #{current_path} ; RAILS_ENV=#{rails_env} bundle exec sidekiq -d -P #{shared_path}/pids/sidekiq.pid -L #{shared_path}/log/sidekiq.log"
  end

  desc 'Start unicorn'
  task :start, except: {no_release: true} do
    run "cd #{current_path} ; RAILS_ENV=#{rails_env} bundle exec unicorn_rails -c config/unicorn.rb -D"
    run "cd #{current_path} ; RAILS_ENV=#{rails_env} bundle exec sidekiq -d -P #{shared_path}/pids/sidekiq.pid -L #{shared_path}/log/sidekiq.log"
  end

  desc 'Stop unicorn'
  task :stop, except: {no_release: true} do
    run "kill -s QUIT `cat #{shared_path}/pids/unicorn.pid`"
    run "cd #{current_path} ; RAILS_ENV=#{rails_env} bundle exec sidekiqctl stop #{shared_path}/pids/sidekiq.pid"
  end

  task :link_config, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{deploy_to}/shared/config/redis.yml #{release_path}/config/redis.yml"
  end
end

namespace :rake do
  desc "Run a task on a remote server."
  # run like: cap staging rake:invoke task=a_certain_task
  task :invoke do
    run("cd #{deploy_to}/current && bundle exec rake #{ENV['task']} RAILS_ENV=#{rails_env}")
  end
end