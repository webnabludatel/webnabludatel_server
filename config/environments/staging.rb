# encoding: utf-8
# так же, как в production
require File.expand_path('../production.rb', __FILE__)
Watcher::Application.configure do
  # оверрайды - сюда
  config.action_mailer.delivery_method = :test
end
