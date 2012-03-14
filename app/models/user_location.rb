# encoding: utf-8

class UserLocation < ActiveRecord::Base
  belongs_to :user
  belongs_to :commission

  has_many :photos, class_name: "UserLocationPhoto", dependent: :destroy, order: :timestamp
  has_many :sos_messages, dependent: :nullify
  has_many :watcher_reports, dependent: :destroy, order: :timestamp

  has_many :user_messages

  has_many :protocol_photos, dependent: :destroy, order: :timestamp
  has_many :protocol_photo_copies, dependent: :destroy, order: :timestamp

  STATUSES = %W(pending approved rejected problem suspicious waiting_for_data)

  validates :status, inclusion: { in: STATUSES }
  validates :user, presence: true
  validates :commission, presence: true

  STATUSES.each do |status|
    class_eval <<-EOF
    scope :#{status}, where(status: :#{status})

    EOF
  end

  reverse_geocoded_by :latitude, :longitude

  after_initialize :set_default_status
  after_save :update_watcher_reports
  after_create :reprocess_delayed_messages

  attr_accessible :latitude, :longitude

  def status
    ActiveSupport::StringInquirer.new("#{read_attribute(:status)}")
  end

  def regulations
    @regulations ||= watcher_reports.where("status != 'training'").where("status != 'broken_timestamp'").regulations
  end

  def violations
    @violations ||= watcher_reports.where("status != 'training'").where("status != 'broken_timestamp'").violations
  end

  def regulations_count
    @regulations_count ||= regulations.size
  end

  def violations_count
    @violations_count ||= violations.size
  end

  def approve!(comment = nil)
    self.status = "approved"
    self.comment = comment

    save
  end

  def reject!(comment = nil)
    self.status = "rejected"
    self.comment = comment

    save
  end

  def problem!(comment = nil)
    self.status = "problem"
    self.comment = comment

    save
  end

  private
    def set_default_status
      if self.status.blank? && self.user && self.user.watcher_status.rejected?
        self.status = "rejected"
      elsif self.status.blank?
        self.status = "pending"
      end
    end

    def update_watcher_reports
      return unless self.status_changed?

      if self.status == "approved"
        self.watcher_reports.each{|r| r.save! }
      elsif self.status == "rejected"
        self.watcher_reports.update_all(status: "rejected")
      elsif self.status == "suspicious"
        self.watcher_reports.update_all(status: "location_suspicious")
      end
    end

    def reprocess_delayed_messages
      puts "Reprocessing delayed messages for: #{self.inspect}"

      Delayed::Job.enqueue UserMessagesReprocessJob.new(self.id)
    end
end
