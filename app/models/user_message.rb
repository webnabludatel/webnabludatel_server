class UserMessage < ActiveRecord::Base
  belongs_to :user
  has_many :device_messages
  has_many :media_items

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
# == Schema Information
#
# Table name: user_messages
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  key        :string(255)
#  value      :string(255)
#  latitude   :decimal(11, 8)
#  longitude  :decimal(11, 8)
#  timestamp  :datetime
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

