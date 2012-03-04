# encoding: utf-8

class WatcherReport < ActiveRecord::Base
  attr_accessible :key, :value, :timestamp, :latitude, :longitude

  belongs_to :user
  belongs_to :user_location
  belongs_to :check_list_item

  has_one :commission, through: :user_location

  has_many :user_messages, dependent: :nullify
  has_many :photos, class_name: "WatcherReportPhoto", dependent: :destroy, order: :timestamp
  has_many :videos, class_name: "WatcherReportVideo", dependent: :destroy, order: :timestamp

  STATUSES = %W(pending approved rejected blocked problem training manual_approved manual_rejected manual_suspicious location_unknown check_location location_not_approved no_location location_suspicious none)
  MEDIA_VIOLATIONS = %W(voters_lists_violations_photo appearance_violation_photo observer_conditions_violations_photo
  pressure_violations_photo suspicious_voters_violations_photo suspicious_voters_violations_video bundle_of_ballots_photo
  bundle_of_ballots_video absentee_vote_violations_photo unused_ballots_violation_photo voters_protocol_recording_violations_photo
  absentee_ballot_box_opening_violations_photo absentee_ballot_box_opening_video ballot_box_opening_violations_photo ballot_box_opening_video
  counting_ballots_violations_photo counting_ballots_violations_video koib_violations_photo protocol_violations_photo)

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

  before_validation :set_status, :set_check_list_item, :set_is_violation

  def status
    ActiveSupport::StringInquirer.new("#{read_attribute(:status)}")
  end

  def title
    check_list_item.title rescue 'неизвестно'
  end

  def section_title
    check_list_item.parent.title rescue 'неизвестно'
  end

  def siblings
    keys = check_list_item.siblings.map(&:name)
    user_location.watcher_reports.where(:key => keys)
  rescue
    []
  end

  protected

    def set_status
      self.status = WatcherReport::StatusCalculator.calculate(self.status, user_location.try(:status), user.try(:watcher_status))
    end

    def set_is_violation
      self.is_violation = check_list_item && value && check_list_item.hi_value == value || MEDIA_VIOLATIONS.include?(check_list_item.name)
      true
    end

    def set_check_list_item
      self.check_list_item = CheckListItem.find_by_name(key) if self.check_list_item.blank?
    end
end
