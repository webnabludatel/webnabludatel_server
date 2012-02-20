#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

require 'annotate/tasks'
ENV['position_in_class']   = "after"
ENV['show_indexes']        = "true"
ENV['exclude_tests']       = "true"
ENV['exclude_fixtures']    = "true"

Watcher::Application.load_tasks
