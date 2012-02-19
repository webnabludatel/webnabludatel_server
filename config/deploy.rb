$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Для работы rvm
require 'rvm/capistrano' # Для работы rvm
require 'bundler/capistrano' # Для работы bundler. При изменении гемов bundler автоматически обновит все гемы на сервере, чтобы они в точности соответствовали гемам разработчика.

server "webnabludatel.ru", :app, :web, :db, :primary => true

set :application, "Webnabludatel"

set :deploy_to, "/server/www/webnabludatel.ru/main/deploy"

set :scm, :git
set :repository, "git://github.com/webnabludatel/webnabludatel_server.git"
set :branch, "master"
set :deploy_via, :remote_cache

set :user, "www-data"
set :use_sudo, false
set :ssh_options, forward_agent: true

set :rvm_ruby_string, '1.9.3' # Это указание на то, какой Ruby интерпретатор мы будем использовать.
set :rvm_type, :system

