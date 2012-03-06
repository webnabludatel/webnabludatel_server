# encoding: utf-8

class ProtocolPhotoCopy < ActiveRecord::Base
  belongs_to :user_location
  belongs_to :media_item

  mount_uploader :image, ProtocolPhotoUploader

  STATUSES = %W(pending approved rejected problem)

  STATUSES.each do |status|
    class_eval <<-EOF
      scope :#{status}, where(status: :#{status})
    EOF
  end
end