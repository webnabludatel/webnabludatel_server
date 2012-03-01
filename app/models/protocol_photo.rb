# encoding: utf-8

class ProtocolPhoto < ActiveRecord::Base
  belongs_to :user_location
  belongs_to :media_items

  mount_uploader :image, ProtocolPhotoUploader
end