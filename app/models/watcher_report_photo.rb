# encoding: utf-8

class WatcherReportPhoto < ActiveRecord::Base

  belongs_to :watcher_report
  belongs_to :media_item

  delegate :user, to: :watcher_report

  STATUSES = %W(pending interesting standard defective trash)

  STATUSES.each do |status|
    class_eval <<-EOF
    scope :#{status}, where(status: :#{status})

    EOF
  end

  validates :status, inclusion: { in: STATUSES }

  mount_uploader :image, WatcherReportPhotoUploader
end