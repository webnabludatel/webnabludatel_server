# encoding: utf-8

class WatcherReportPhoto < ActiveRecord::Base
  belongs_to :watcher_report
  belongs_to :media_item

  mount_uploader :image, WatcherReportPhotoUploader
end