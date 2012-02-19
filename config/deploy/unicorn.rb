set :unicorn_conf, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{shared_path}/pids/unicorn.pid"

namespace :deploy do
  desc "Restarts Unicorn server with zero-downtime. If Unicorn server is running, sends USR2 signal to the master process, otherwise starts up the server as usual."
  task :restart, :roles => :app do
    run "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -USR2 `cat #{unicorn_pid}`; else cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D; fi"
  end

  desc "Starts up the Unicorn server."
  task :start, :roles => :app do
    run "bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D"
  end

  desc "Stops the Unicorn server. Preforms graceful shutdown using QUIT signal."
  task :stop, :roles => :app do
    run "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
  end
end