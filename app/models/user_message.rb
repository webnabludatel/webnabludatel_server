class UserMessage < ActiveRecord::Base
  belongs_to :user
  has_many :device_messages
  has_many :media_items

  belongs_to :user_location

  #has_one :watcher_report, dependent: :destroy
  #after_save :set_watcher_report

  private
  #def set_watcher_report
  #  watcher_report = self.watcher_report || WatcherReport.new
  #  watcher_report.device_message = self
  #
  #  watcher_report.recorded_at = Time.at(self.message["timestamp"].to_i)
  #  watcher_report.user = self.user
  #
  #  watcher_report.comission = self.user.current_comission
  #
  #  watcher_report.key = self.message["key"]
  #  watcher_report.value = self.message["value"]
  #
  #  plist_item = WatcherAttribute.find_by_name! self.message["key"]
  #  watcher_report.watcher_attribute = plist_item
  #
  #  watcher_report.save!
  #end

end
