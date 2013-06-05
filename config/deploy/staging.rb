set :deploy_to, "/var/www/sites/#{application}"
set :rails_env, "production"
set :branch, "master"
# set :rails_env, "staging"
# set :branch, "staging"
set :unicorn_pid, "#{deploy_to}/current/tmp/pids/unicorn.pid"

# Server innercircle(production)
role :app, "108.166.93.213:2012"
role :web, "108.166.93.213:2012"
role :db,  "108.166.93.213:2012", :primary => true

