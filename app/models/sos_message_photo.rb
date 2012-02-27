# encoding: utf-8

class SosMessagePhoto < ActivRecord::Base
  belongs_to :sos_message
  belongs_to :user_media

  mount_uploader :image, SosMessageImageUploader
end