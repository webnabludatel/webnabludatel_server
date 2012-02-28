# encoding: utf-8

class WatcherReport < ActiveRecord::Base
  attr_accessible :key, :value, :timestamp, :latitude, :longitude

  belongs_to :user
  belongs_to :user_location
  belongs_to :check_list_item

  has_many :user_messages, dependent: :nullify

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

  protected

    def set_status
      self.status = WatcherReport::StatusCalculator.calculate(self.status, user_location.try(:status), user.try(:watcher_status))
    end

    def set_is_violation
      self.is_violation = check_list_item && value && check_list_item.hi_value == value
      true
    end

    def set_check_list_item
      self.check_list_item = CheckListItem.find_by_name(key) if self.check_list_item.blank?
    end
end
