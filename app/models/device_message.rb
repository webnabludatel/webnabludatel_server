# encoding: utf-8

class DeviceMessage < ActiveRecord::Base
  belongs_to :user

  has_one :watcher_report, dependent: :destroy

  serialize :message

  after_create :create_watcher_report, if: Proc.new{ self.message["MSG_TYPE"] == "post" }

  attr_accessible :message

  private
    def create_watcher_report
      watcher_report = self.watcher_report.new recorded_at: Time.at(self.message["TIMESTAMP"].to_i)
      watcher_report.user = self.user

      watcher_report.comission = self.user.current_comission

      watcher_report.key = self.message["PAYLOAD"] && self.message["PAYLOAD"].keys.first
      watcher_report.value = self.message["PAYLOAD"] && self.message["PAYLOAD"][watcher_report.key]

      watcher_report.save!
    end
end