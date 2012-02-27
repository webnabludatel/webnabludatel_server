class MediaItem < ActiveRecord::Base
  belongs_to :user_message
  belongs_to :user
end
