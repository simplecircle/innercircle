require 'bundler/capistrano'
require 'capistrano/ext/multistage'
require './config/boot'
require 'sidekiq/capistrano'

set :stages, %w(production staging)
set :default_stage, "staging"

# Application "Name" and server info.
set :application, "innercircle"

# The user you are using to deploy with (This user should have SSH access to your server)
set :user, "deploy"
set :ssh_options, {:forward_agent => true}

# Github repo
set :repository,  "git@github.com:simplecircle/innercircle.git"
set :scm, :git
# scm_passphrase is not needed cause the ssh key does not require an additional password.
# It's set to blank so you do not need to hit return when prompted for the pwd however.
set :scm_passphrase, ""

# Where to deploy your application to.
set :deploy_to, "/var/www/sites/#{application}"

# Deploy everything under your user, we don't want to use sudo.
set :use_sudo, false

# Pull branch and create a cache of the repo in the shared dir, for quicker future deploys.
set :deploy_via, :remote_cache
set :git_shallow_clone, 1

# Additional flags are not needed on the sidekiq call cause sidekiq/capistrano appends them as needed.
set :sidekiq_cmd, "bundle exec sidekiq"
set :sidekiqctl_cmd, "bundle exec sidekiqctl"
set :sidekiq_timeout, 10
set :sidekiq_role, :app
set :sidekiq_pid, "#{current_path}/tmp/pids/sidekiq.pid"
set :sidekiq_processes, 1

after "deploy:update_code".to_sym do
  upload "config/database.yml.cap", "#{release_path}/config/database.yml", :mode => 0444
  # system "bundle exec rake assets:precompile"
  upload "public/manifest.yml", "#{release_path}/public/manifest.yml" ,:mode => 0444
  system "bundle exec rake RAILS_ENV=#{stage} assets:sync"
end


# Swap in the maintenance page
namespace :web do
  desc "USE THIS VERSION - Put up the maintenance page"
  task :disable, :roles => :web do
    on_rollback { run "rm #{shared_path}/system/maintenance.html" }
    run "ln -s #{current_path}/public/maintenance.html #{shared_path}/system/maintenance.html"
  end
  desc "USE THIS VERSION - Take down the maintenance page"
  task :enable, :roles => :web do
    run "rm #{shared_path}/system/maintenance.html"
  end
end

namespace :unicorn do
  desc "Stop unicorn"
  task :stop, :roles => :app do
    run "if [ -e #{unicorn_pid} ]; then kill -QUIT `cat #{unicorn_pid}`; rm #{unicorn_pid}; fi"
  end

  desc "Start unicorn"
  task :start, :roles => :app do
    run "cd #{current_path} && bundle exec unicorn_rails -E #{stage} -D -c #{current_path}/config/unicorn.rb"
  end

  desc "Restart unicorn"
  task :restart, :roles =>:app do
    unicorn.stop
    unicorn.start
    # run "kill -s USR2 `cat #{unicorn_pid}`"
  end
end

namespace :deploy do
  desc "Restart unicorn"
  task :restart, :roles => :app do
    unicorn.restart
  end
end

task :uname do
  run "uname -a"
end

