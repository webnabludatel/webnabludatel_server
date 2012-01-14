source 'http://rubygems.org'

gem 'rails', '3.1.3'

gem 'pg'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.5'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'carrierwave'
gem 'devise'
gem 'haml-rails'
gem 'jquery-rails'
gem 'kaminari'
gem 'mini_magick'

group :development do
  gem 'unicorn'

  gem 'capistrano'
  gem 'capistrano-ext'

  gem 'guard'
  gem 'guard-annotate'
  gem 'guard-rspec'
  gem 'guard-bundler'
  gem 'guard-migrate'
  gem 'guard-spork'
  gem 'rb-fsevent'

  gem 'ruby_gntp' # for Growl notifications, works only with Growl >= 1.3

  gem 'yard'
end

group :development, :test do
  gem 'autotest'
  gem 'capybara', :git => 'https://github.com/jnicklas/capybara.git'
  gem 'database_cleaner'
  gem 'fabrication'
  gem 'ffaker'
  gem 'fuubar'
  gem 'rspec-rails'
  gem 'spork', '> 0.9.0.rc'
  gem 'steak'
  gem 'timecop'
end