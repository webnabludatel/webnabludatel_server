class UserMessage < ActiveRecord::Base
  serialize :processing_errors

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

  private

    # analyze message only if 'key' or 'value' attribute has been changed
    def process
      Delayed::Job.enqueue AnalyzeUserMessageJob.new(self.id) if (%W(key value) & changed).present?
    end

end
