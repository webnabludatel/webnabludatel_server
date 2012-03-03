$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Для работы rvm
require 'rvm/capistrano'
require 'capistrano-deploy'

use_recipes :multistage, :bundle

set :default_stage, :production

stage :staging do
  set :rails_env, 'staging'
  server '176.34.68.134', :app, :web, :db, :primary => true
end

stage :production do
  require 'airbrake/capistrano'
  set :rails_env, 'production'
  server '176.34.112.34', :app, :web, :db, :primary => true
end

set :application, 'webnabludatel.ru'

set :deploy_to, "/server/www/#{application}/main/deploy"

set :scm, :git
set :repository, 'git://github.com/webnabludatel/webnabludatel_server.git'
set :branch, 'production'
set :deploy_via, :remote_cache

set :user, 'www-data'
set :use_sudo, false
set :ssh_options, forward_agent: true

set :rvm_ruby_string, '1.9.3@webnabludatel'
set :rvm_type, :system

set :normalize_asset_timestamps, false # Don't need in rails 3

depend :remote, :gem, 'bundler', '>=1.0.21'

after 'deploy:update', 'bundle:install'
after 'deploy', 'deploy:cleanup' # keeps only last 5 releases
