class UserMessage < ActiveRecord::Base
  serialize :processing_errors
  search_methods :with_processing_errors

  belongs_to :user
  has_many :device_messages
  has_many :media_items, dependent: :destroy

  belongs_to :user_location
  belongs_to :watcher_report

  after_save :process

  scope :delayed, where(is_delayed: false)
  scope :with_processing_errors, where("processing_errors is not null and processing_errors != ?", YAML.dump([]))

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

    # analyze message only if 'key' or 'value' attribute has been changed
    def process
      Delayed::Job.enqueue AnalyzeUserMessageJob.new(self.id) if (%W(key value) & changed).present?
    end

end
