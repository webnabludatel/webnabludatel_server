# encoding: utf-8

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :timeoutable
  devise :database_authenticatable, :registerable, :confirmable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  attr_accessible :email, :password, :password_confirmation, :remember_me

  belongs_to :organization

  has_many :device_messages, dependent: :destroy
  has_one :refferal, class_name: "WatcherRefferal", dependent: :destroy

  WATCHER_STATUSES = [:pending, :approved, :rejected, :problem, :blocked, :none]

  scope :admins, where(role: "admin")
  scope :moderators, where(role: "moderators")
  scope :watchers, where(is_watcher: true)

  WATCHER_STATUSES.each do |status|
    class_eval <<-EOF
    scope :#{status}, watchers.where(status: :#{status})

    EOF
  end

  validates :watcher_status, inclusion: { in: WATCHER_STATUSES }

  after_initialize :set_default_watcher_status

  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token.extra.raw_info
    User.where(email: data.email).first || User.create!(email: data.email, password: Devise.friendly_token[0,20])
  end

  protected
    def set_default_watcher_status
      self.watcher_status = :none if self.watcher_status.blank?
    end

end
