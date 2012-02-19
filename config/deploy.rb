$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Для работы rvm
require 'rvm/capistrano'
require 'bundler/capistrano'
require 'airbrake/capistrano'

server "176.34.112.34", :app, :web, :db, :primary => true

set :application, "WebNabludatel"

set :deploy_to, "/server/www/webnabludatel.ru/main/deploy"

set :scm, :git
set :repository, "git://github.com/webnabludatel/webnabludatel_server.git"
set :branch, "origin/production"
set :deploy_via, :remote_cache

set :user, "www-data"
set :use_sudo, false
set :ssh_options, forward_agent: true

set :rvm_ruby_string, '1.9.3' # Это указание на то, какой Ruby интерпретатор мы будем использовать.
set :rvm_type, :system

