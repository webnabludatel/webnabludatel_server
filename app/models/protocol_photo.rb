# encoding: utf-8

class ProtocolPhoto < ActiveRecord::Base
  belongs_to :user_location
  belongs_to :media_item

  mount_uploader :image, ProtocolPhotoUploader

  delegate :commission, to: :user_location
  delegate :user, to: :user_location

  STATUSES = %W(pending approved rejected problem)

  STATUSES.each do |status|
    class_eval <<-EOF
      scope :#{status}, where(status: :#{status})
    EOF
  end

end