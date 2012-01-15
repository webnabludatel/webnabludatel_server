# encoding: utf-8

class WatcherRefferal < ActiveRecord::Base
  belongs_to :watcher

  STATUSES = [:pending, :approved, :rejected, :problem]

  validates :watcher, presence: true
  validates :status, inclusion: { in: STATUSES }

  STATUSES.each do |status|
    class_eval <<-EOF
    scope :#{status}, where(status: :#{status})

    EOF
  end

  scope :not_done, where("status = 'approved' OR status = 'problem'")

  mount_uploader :image, WatcherRefferalImageUploader

  attr_accessible :comment

  def approve!(comment = nil)
    self.status = :approve
    self.comment = comment

    save
  end

  def reject!(comment = nil)
    self.status = :rejected
    self.comment = comment

    save
  end

  def problem!(comment = nil)
    self.status = :problem
    self.comment = comment

    save
  end

  protected
    def update_watcher_state
      if status != status_was
        self.watcher.status = status
        self.watcher.save
      end
    end
end