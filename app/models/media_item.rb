class MediaItem < ActiveRecord::Base
  belongs_to :user_message

  after_create :process

  private
    def process
      analyzer = MediaItemAnalyzer.new self
      analyzer.process!
    end
end
