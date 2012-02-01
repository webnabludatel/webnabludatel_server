class WatcherReport < ActiveRecord::Base
  belongs_to :user
  belongs_to :comission
  belongs_to :device_message

  attr_accessible :key, :value, :recorded_at
end