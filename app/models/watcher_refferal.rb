class WatcherRefferal < ActiveRecord::Base
  belongs_to :watcher

  STATUSES = [:pending, :approved, :rejected, :problem]

  validates :watcher, :presence => true
  validates :status, :inclusion => { :in => STATUSES }

  mount_uploader :image, WatcherRefferalImageUploader

  attr_accessible :comment
end