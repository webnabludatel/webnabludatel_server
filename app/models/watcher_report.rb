# encoding: utf-8

class WatcherReport < ActiveRecord::Base
  attr_accessible :key, :value, :recorded_at, :latitude, :longitude

  belongs_to :user
  belongs_to :commission
  belongs_to :device_message
  belongs_to :watcher_attribute

  STATUSES = %W(pending approved rejected blocked problem training manual_approved manual_rejected manual_suspicious location_unknown check_location location_not_approved no_location location_suspicious none)

  (STATUSES - %W"approved rejected manual_approved manual_rejected").each do |status|
    class_eval <<-EOF
    scope :#{status}, where(status: :#{status})

    EOF
  end

  scope :approved, where("status = 'approved' OR status = 'manual_approved'")
  scope :rejected, where("status = 'rejected' OR status = 'manual_rejected'")

  validates :key, presence: true
  validates :value, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  before_validation :set_status, :set_watcher_attribute, :set_is_violation

  def status
    ActiveSupport::StringInquirer.new("#{read_attribute(:status)}")
  end

  def user_location
    @user_location ||= self.commission ? self.commission.user_locations.where(user_id: self.user).first : nil
  end

  protected

    def set_status
      self.status = WatcherReport::StatusCalculator.calculate(self.status, user_location.try(:status), user.try(:watcher_status))
    end

    def set_is_violation
      self.is_violation = watcher_attribute && value && watcher_attribute.hi_value == value
      true
    end

    def set_watcher_attribute
      self.watcher_attribute = WatcherAttribute.find_by_name(key) if self.watcher_attribute.blank?
    end
end
# == Schema Information
#
# Table name: watcher_reports
#
#  id                        :integer         not null, primary key
#  key                       :string(255)
#  value                     :string(255)
#  recorded_at               :datetime
#  is_violation              :boolean
#  user_id                   :integer
#  comission_id              :integer
#  device_message_id         :integer
#  image                     :string(255)
#  video_path                :string(255)
#  status                    :string(255)
#  created_at                :datetime        not null
#  updated_at                :datetime        not null
#  watcher_checklist_item_id :integer
#
# Indexes
#
#  index_watcher_logs_on_comission_id                  (comission_id)
#  index_watcher_logs_on_device_message_id             (device_message_id)
#  index_watcher_logs_on_user_id                       (user_id)
#  index_watcher_reports_on_watcher_checklist_item_id  (watcher_checklist_item_id)
#

