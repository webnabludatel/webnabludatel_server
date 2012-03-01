# encoding: utf-8

class WatcherReportVideo < ActiveRecord::Base
  belongs_to :watcher_report
  belongs_to :media_item
end