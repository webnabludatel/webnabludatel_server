class UserMessage < ActiveRecord::Base
  belongs_to :user
  has_many :device_messages
  has_many :media_items, dependent: :destroy

  belongs_to :user_location
  belongs_to :watcher_report

  after_save :process

  scope :delayed, where(is_delayed: false)

  private
    def process
      Delayed::Job.enqueue AnalyzeUserMessageJob.new(self.id)
    end

end
