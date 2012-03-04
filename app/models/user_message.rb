class UserMessage < ActiveRecord::Base
  belongs_to :user
  has_many :device_messages
  has_many :media_items, dependent: :destroy

  belongs_to :user_location
  belongs_to :watcher_report

  after_save :process

  scope :delayed, where(is_delayed: false)

  def processing_errors
    read_attribute(:processing_errors) || write_attribute(:processing_errors, [])
  end

  def old_api?
    data = JSON.parse(device_messages.last.payload)
    data.has_key?("polling_place_region") && data.has_key?("polling_place_id")
  end

  def new_api?
    data = JSON.parse(device_messages.last.payload)
    data.has_key?("polling_place_internal_id")
  end

  private
    def process
      Delayed::Job.enqueue AnalyzeUserMessageJob.new(self.id)
    end

end
