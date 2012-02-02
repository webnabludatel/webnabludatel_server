class WatcherReport < ActiveRecord::Base
  belongs_to :user
  belongs_to :comission
  belongs_to :device_message

  validates :key, presence: true
  validates :value, presence: true

  STATUSES = %W(pending approved rejected problem training manual_rejected manual_suspicious location_unknown check_location location_not_approved no_location)

  STATUSES.each do |status|
    class_eval <<-EOF
    scope :#{status}, where(status: :#{status})

    EOF
  end

  attr_accessible :key, :value, :recorded_at

  def status
    ActiveSupport::StringInquirer.new("#{read_attribute(:status)}")
  end
end