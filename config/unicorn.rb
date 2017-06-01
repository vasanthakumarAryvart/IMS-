# config/unicorn.rb
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 15
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end

## config/unicorn.rb
## Set environment to development unless something else is specified
#
#app_dir = File.expand_path '../../', __FILE__
#
#shared_path = File.expand_path '../../../../shared/', __FILE__
#
#env = ENV['RAILS_ENV'] || 'development'
#
## See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
## documentation.
#worker_processes 4
#
## listen on both a Unix domain socket and a TCP port,
## we use a shorter backlog for quicker failover when busy
#
#listen 8085, :backlog => 256
#listen "#{shared_path}/sockets/unicorn.socket", :backlog => 256
#
## Preload our app for more speed
#preload_app true
#
## nuke workers after 30 seconds instead of 60 seconds (the default)
#timeout 30
#
#pid "#{shared_path}/pids/unicorn.pid"
#
## Production specific settings
#if env == 'staging'
#  # Help ensure your application will always spawn in the symlinked
#  # 'current' directory that Capistrano sets up.
#  working_directory app_dir
#
#  # feel free to point this anywhere accessible on the filesystem
#  # worker_processes 2
#
#  stderr_path "#{shared_path}/log/unicorn.stderr.log"
#  stdout_path "#{shared_path}/log/unicorn.stdout.log"
#end
#
#before_fork do |server, worker|
#  # the following is highly recomended for Rails + 'preload_app true'
#  # as there's no need for the master process to hold a connection
#  if defined?(ActiveRecord::Base)
#    ActiveRecord::Base.connection.disconnect!
#  end
#
#  # Before forking, kill the master process that belongs to the .oldbin PID.
#  # This enables 0 downtime deploys.
#  old_pid = "#{shared_path}/pids/unicorn.pid.oldbin"
#  if File.exists?(old_pid) && server.pid != old_pid
#    begin
#      Process.kill('QUIT', File.read(old_pid).to_i)
#    rescue Errno::ENOENT, Errno::ESRCH
#      # someone else did our job for us
#    end
#  end
#end
#
#after_fork do |server, worker|
#  # the following is *required* for Rails + 'preload_app true',
#  if defined?(ActiveRecord::Base)
#    ActiveRecord::Base.establish_connection
#  end
#
#  # if preload_app is true, then you may also want to check and
#  # restart any other shared sockets/descriptors such as Memcached,
#  # and Redis.  TokyoCabinet file handles are safe to reuse
#  # between any number of forked children (assuming your kernel
#  # correctly implements pread()/pwrite() system calls)
#end
