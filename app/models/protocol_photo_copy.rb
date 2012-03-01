# encoding: utf-8

class ProtocolPhotoCopy < ActiveRecord::Base
  belongs_to :user_location
  belongs_to :media_items

  mount_uploader :image, ProtocolPhotoUploader
end