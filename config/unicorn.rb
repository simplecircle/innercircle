p rails_env = ENV['RAILS_ENV'] || 'production'
if rails_env == "development" or rails_env == "test"
  p app_root = "/Users/#{ENV['USER']}/Sites/innercircle_project/innercircle/"
  worker_processes 2
else
  p app_root = "/var/www/sites/innercircle/current/"
  stderr_path "#{app_root}log/unicorn.stderr.log"
  stdout_path "#{app_root}log/unicorn.stdout.log"
  working_directory app_root
  worker_processes 2
end

preload_app true
# This long timout is to allow for Facebook batch imports. It's just
# 5 secs longer than nginx's read_proxy_timeout.
timeout 105

# This is where we specify the socket. Nginx module points to this.
listen "#{app_root}tmp/sockets/unicorn.sock", :backlog => 64
pid "#{app_root}tmp/pids/unicorn.pid"

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!

  old_pid = "#{app_root}tmp/pids/unicorn.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end
