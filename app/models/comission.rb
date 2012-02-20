# encoding: utf-8

class Comission < ActiveRecord::Base
  has_many :user_locations, dependent: :destroy
  has_many :users, through: :user_locations
  has_many :watcher_reports, dependent: :destroy

  # TODO: add validations

  STATUSES = %W(pending approved rejected)

  validates :status, presence: true, inclusion: { in: STATUSES }

  STATUSES.each do |status|
    class_eval <<-EOF
    scope :#{status}, where(status: :#{status})

    EOF
  end

  before_validation :set_default_status

  geocoded_by :address
  after_validation :geocode

  def status
    ActiveSupport::StringInquirer.new("#{read_attribute(:status)}")
  end

  protected
    def set_default_status
      self.status = "pending"
    end
end
# == Schema Information
#
# Table name: comissions
#
#  id         :integer         not null, primary key
#  number     :string(255)
#  latitude   :float
#  longitude  :float
#  kind       :string(255)
#  address    :text
#  created_at :datetime
#  updated_at :datetime
#  status     :string(255)
#

