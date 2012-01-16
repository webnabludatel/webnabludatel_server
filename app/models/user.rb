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
  has_many :user_locations, dependent: :destroy
  has_many :comissions, :through => :user_locations

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

  after_initialize  :set_default_watcher_status
  before_update     :generate_confirmation_token, if: :reconfirmation_required?
  after_update      :send_confirmation_instructions, if: :reconfirmation_required?

  def self.find_or_create_by_omniauth!(omniauth)
    user = Authentication.find_by_provider_and_uid(omniauth['provider'].to_s, omniauth['uid'].to_s).try(:user)

    if user.blank?
      user = User.find_by_email(omniauth['info']['email']) || User.new
      user.register_omniauth!(omniauth)
    end

    user
  end

  def register_omniauth!(omniauth)
    self.omniauth_data = omniauth
    unless authentications.exists?(provider: omniauth['provider'].to_s)
      extract_omniauth_data
      save!
      authentications.create(provider: omniauth['provider'].to_s, uid: omniauth['uid'].to_s)
    end
  end

  def watcher_status
    ActiveSupport::StringInquirer.new("#{read_attribute(:watcher_status)}")
  end

  # TODO: Maybe we need to cache it in DB
  def current_location
    @current_location ||= user_locations.order("created_at DESC").first
  end

  # TODO: Maybe we need to cache it in DB
  def current_comission
    @current_comission ||= current_location.try(:comission)
  end

  def to_s
    name.presence || email.presence || authentications.first.to_s
  end

  protected

  def extract_omniauth_data
    %W(name first_name last_name location phone).each do |attr|
      write_attribute(attr, omniauth_data['info'][attr]) if read_attribute(attr).blank?
    end

    self.urls ||= {}
    self.urls.reverse_merge!(omniauth_data['info']['urls'].presence || {})

    # Vkontakte-specific attribute
    self.birth_date ||= omniauth_data['extra']['raw_info']['bdate'].try(:to_date)
  end

  def email_required?
    omniauth_data.blank?
  end

  def password_required?
    omniauth_data.blank? && (!persisted? || !password.nil? || !password_confirmation.nil?)
  end

  def confirmation_required?
    omniauth_data.blank?
  end

  def reconfirmation_required?
    email_changed? || (email.present? && confirmation_token.blank? && confirmed_at.blank? && confirmation_sent_at.blank?)
  end

  def set_default_watcher_status
    self.watcher_status = "none" if self.watcher_status.blank?
  end
end
