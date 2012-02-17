# encoding: utf-8

class Authentication < ActiveRecord::Base
  DEVICE_PROVIDER = 'device'

  belongs_to :user

  scope :devices, where(provider: DEVICE_PROVIDER)

  validates :provider, :uid, presence: true
  validates :provider, uniqueness: { scope: :uid }

  def self.for_device(device_id)
    where(provider: DEVICE_PROVIDER, uid: device_id.to_s).first
  end

  def self.register_device!(device_id, email)
    user = User.new(email: email)
    auth = user.authentications.build(
        provider: DEVICE_PROVIDER,
        uid: device_id,
        secret: SecureRandom.hex(16)
    )

    unless user.save
      auth.errors.add(:user, user.errors.full_messages.first)
    end

    auth
  end

  def to_s
    "#{provider}(#{uid})"
  end
end
