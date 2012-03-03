$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Для работы rvm
require 'rvm/capistrano'
require 'bundler/capistrano'

task :production do
  require 'airbrake/capistrano'
  server '176.34.112.34', :app, :web, :db, :primary => true
  set :branch, 'production'
end

task :staging do
  server 'ec2-176-34-68-134.eu-west-1.compute.amazonaws.com', :app, :web, :db, :primary => true
  set :rails_env, 'staging'
  # default - master. оверрайдить так:
  # cap staging deploy -s branch=production
  #set :branch, 'staging'
end

set :application, 'webnabludatel.ru'

set :deploy_to, "/server/www/#{application}/main/deploy"

set :scm, :git
set :repository, 'git://github.com/webnabludatel/webnabludatel_server.git'
set :deploy_via, :remote_cache

set :user, 'www-data'
set :use_sudo, false
set :ssh_options, forward_agent: true

set :rvm_ruby_string, '1.9.3@webnabludatel'
set :rvm_type, :system

set :normalize_asset_timestamps, false # Don't need in rails 3

depend :remote, :gem, 'bundler', '>=1.0.21'

after 'deploy', 'deploy:cleanup' # keeps only last 5 releases
