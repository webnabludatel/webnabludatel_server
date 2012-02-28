# encoding: utf-8

class SosMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_message
  belongs_to :location, :class_name => "UserLocation"

  has_many :photos, class_name: "SosMessagePhoto", dependent: :destroy
end