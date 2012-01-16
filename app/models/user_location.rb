# encoding: utf-8

class UserLocation < ActiveRecord::Base
  belongs_to :user
  belongs_to :comission

  STATUSES = %W(pending approved rejected suspicious)

  validates :status, inclusion: { in: STATUSES }
  validates :user, :presence => true
  validates :comission, :presence => true

  STATUSES.each do |status|
    class_eval <<-EOF
    scope :#{status}, where(status: :#{status})

    EOF
  end

  after_initialize :set_default_status

  attr_accessible :latitude, :longitude

  def status
    ActiveSupport::StringInquirer.new("#{read_attribute(:status)}")
  end

  private
    def set_default_status
      self.status = "pending" if self.status.blank?
    end
end