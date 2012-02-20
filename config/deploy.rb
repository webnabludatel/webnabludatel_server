$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Для работы rvm
require 'rvm/capistrano'
require 'bundler/capistrano'
require 'airbrake/capistrano'

server '176.34.112.34', :app, :web, :db, :primary => true

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

after 'deploy', 'deploy:cleanup' # keeps only last 5 releases
