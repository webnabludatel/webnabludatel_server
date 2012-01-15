# encoding: utf-8

class WatcherReferal < ActiveRecord::Base
  belongs_to :user

  STATUSES = [:pending, :approved, :rejected, :problem]

  validates :user, presence: true
  validates :status, inclusion: { in: STATUSES }

  STATUSES.each do |status|
    class_eval <<-EOF
    scope :#{status}, where(status: :#{status})

    EOF
  end

  scope :not_done, where("status = 'approved' OR status = 'problem'")

  mount_uploader :image, WatcherReferalImageUploader

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
        self.user.watcher_status = status
        self.user.watcher_status.save
      end
    end
end