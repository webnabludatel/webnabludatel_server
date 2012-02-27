class MediaItem < ActiveRecord::Base
  belongs_to :user_message
  belongs_to :user

  before_save :sync_user
  after_create :process

  private
    def sync_user
      self.user ||= user_message.user
    end

    def process
      Delayed::Job.enqueue AnalyzeMediaJob.new(self.id)
    end
end
