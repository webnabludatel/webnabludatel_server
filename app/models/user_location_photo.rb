class UserLocationPhoto < ActiveRecord::Base
  belongs_to :user_location
  belongs_to :meida_item

  mount_uploader :image, UserLocationImageUploader
end