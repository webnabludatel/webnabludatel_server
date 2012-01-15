# encoding: utf-8

class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :confirmable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :name, :first_name, :last_name, :location, :phone, :urls, :birth_date

  attr_accessor :omniauth_data

  serialize :urls

  belongs_to :organization

  has_many :authentications, dependent: :destroy
  has_many :device_messages, dependent: :destroy
  has_one :referal, class_name: "WatcherReferal", dependent: :destroy

  WATCHER_STATUSES = %W(pending approved rejected problem blocked none)

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

  def self.find_or_create_by_omniauth!(omniauth)
    user = Authentication.find_by_provider_and_uid(omniauth['provider'].to_s, omniauth['uid'].to_s).try(:user)

    if user.blank?
      user = User.find_by_email(omniauth['info']['email']) || User.new
      user.register_omniauth(omniauth)
    end

    user
  end

  def register_omniauth(omniauth)
    self.omniauth_data = omniauth
    unless authentications.exists?(provider: omniauth['provider'].to_s)
      extract_omniauth_data
      self.authentications.build(provider: omniauth['provider'].to_s, uid: omniauth['uid'].to_s)
      self.save
    end
  end

  protected

  def extract_omniauth_data
    omniauth_data['info'].each do |k, v|
      write_attribute(k, v) if attribute_names.include?(k) && read_attribute(k).blank?
    end

    # TODO: look on birth_date extraction and on merging of urls fields
  end

  def password_required?
    omniauth_data.blank? && (!persisted? || !password.nil? || !password_confirmation.nil?)
  end

  def email_required?
    omniauth_data.blank?
  end

  def watcher_status
    ActiveSupport::StringInquirer.new("#{read_attribute(:watcher_status)}")
  end

  def set_default_watcher_status
    self.watcher_status = "none" if self.watcher_status.blank?
  end

end
