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
      analyzer = MediaItemAnalyzer.new self
      analyzer.process!
    end
end
