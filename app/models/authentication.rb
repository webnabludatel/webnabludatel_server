# encoding: utf-8

class Authentication < ActiveRecord::Base
  DEVICE_PROVIDER = 'device'

  belongs_to :user

  validates :provider, :uid, presence: true
  validates :provider, uniqueness: {scope: :user_id}

  def self.find_for_device_authentication(device_id)
    where(:provider => DEVICE_PROVIDER, :uid => device_id.to_s).first
  end

  def to_s
    "#{provider}(#{uid})"
  end
end
