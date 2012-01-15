source 'http://rubygems.org'

gem 'rails', '3.1.3'
gem 'pg'

gem 'auditor'
gem 'cancan'
gem 'carrierwave'
gem 'delayed_job_active_record'
gem 'devise'
gem 'devise-russian'
gem 'flash_messages_helper'
gem 'geocoder'
gem 'haml-rails'
gem 'jquery-rails'
gem 'kaminari'
gem 'mini_magick'
gem 'omniauth-facebook'
gem 'omniauth-vkontakte'
gem 'russian'
gem 'simple_form'

group :assets do
  gem 'sass-rails',   '~> 3.1.5'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'unicorn'

  gem 'capistrano'
  gem 'capistrano-ext'

  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-migrate'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'rb-fsevent'

  gem 'ruby_gntp' # for Growl notifications, works only with Growl >= 1.3

  gem 'yard'
end

group :development, :test do
  gem 'capybara', git: 'https://github.com/jnicklas/capybara.git'
  gem 'database_cleaner'
  gem 'fabrication'
  gem 'ffaker'
  gem 'fuubar'
  gem 'rspec-rails'
  gem 'spork', '> 0.9.0.rc'
  gem 'steak'
  gem 'timecop'
end