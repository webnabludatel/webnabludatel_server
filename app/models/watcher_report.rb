class WatcherReport < ActiveRecord::Base
  belongs_to :user
  belongs_to :comission
  belongs_to :device_message

  STATUSES = %W(pending approved rejected blocked problem training manual_approved manual_rejected manual_suspicious location_unknown check_location location_not_approved no_location location_suspicious none)

  validates :key, presence: true
  validates :value, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  (STATUSES - %W"approved rejected manual_approved manual_rejected").each do |status|
    class_eval <<-EOF
    scope :#{status}, where(status: :#{status})

    EOF
  end

  scope :approved, where("status = 'approved' OR status = 'manual_approved'")
  scope :rejected, where("status = 'rejected' OR status = 'manual_rejected'")

  attr_accessible :key, :value, :recorded_at

  before_validation :set_status

  def status
    ActiveSupport::StringInquirer.new("#{read_attribute(:status)}")
  end

  def user_location
    @user_location ||= self.comission ? self.comission.user_locations.where(user_id: self.user).first : nil
  end

  protected

    def set_status
      self.status = WatcherReport::StatusCalculator.calculate(self.status, user_location.try(:status), user.try(:watcher_status))
    end
end