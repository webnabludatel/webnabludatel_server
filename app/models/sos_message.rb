# encoding: utf-8

class SosMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_message
  belongs_to :location, :class_name => "UserLocation", foreign_key: :user_location_id
  belongs_to :last_changed_user, :class_name => 'User'

  has_many :photos, class_name: "SosMessagePhoto", dependent: :destroy
  has_many :videos, class_name: "SosMessageVideo", dependent: :destroy

  STATUS = %w(new in_progress done rejected)

  scope :active, where(:status => ["new", "in_progress"])

  before_create :set_status

  def set_status
    self.status = 'new'
  end

end