class UserMessage < ActiveRecord::Base
  belongs_to :user
  has_many :device_messages
  has_many :media_items

  belongs_to :user_location

  after_save :process

  private
    def process
      analyzer = UserMessagesAnalyzer.new self
      analyzer.process!
    end

end
