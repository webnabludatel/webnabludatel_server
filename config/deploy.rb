set :application, "Webnabludatel"

set :scm, :git
set :repository,  "git@github.com:webnabludatel/webnabludatel_server.git"
set :branch, "master"
ssh_options[:forward_agent] = true

server "webnabludatel.ru", :app, :web, :db, :primary => true
set :user, "www-data"
set :use_sudo, false
set :deploy_to, "/server/www/webnabludatel.ru/main/deploy"
set :rails_env, "production"

after "deploy:update_code", "deploy:symlink_shared"

namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end

   desc "Link in the production database.yml and assets"
   task :symlink_shared do
     run "ln -nfs #{deploy_to}/shared/system/database.yml #{release_path}/config/database.yml"
   end
end

namespace :admin do

  desc "tail production log files"
  task :tail_logs, :roles => :app do
    run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
      puts # for an extra line break before the host name
      puts "#{channel[:host]}: #{data}"
      break if stream == :err
    end
  end

end
