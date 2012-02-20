# encoding: utf-8

class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable, :confirmable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :name, :first_name, :last_name, :location, :phone, :urls, :birth_date

  serialize :urls

  belongs_to :organization

  has_many :authentications, dependent: :destroy
  has_many :device_messages, dependent: :destroy
  has_one :referal, class_name: "WatcherReferal", dependent: :destroy
  has_many :user_locations, dependent: :destroy
  has_many :comissions, through: :user_locations
  has_many :device_messages, dependent: :destroy
  has_many :watcher_reports, dependent: :destroy

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
  # TODO: Maybe we need to move it to an observer
  after_save        :update_watcher_reports

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

  def has_email?
    email.present? || unconfirmed_email.present?
  end

  def to_s
    name.presence || email.presence || authentications.first.to_s
  end

  def apply_omniauth(omniauth)
    extract_omniauth_data(omniauth)
    authentications.build(
        provider: omniauth['provider'],
        uid: omniauth['uid'],
        token: omniauth['credentials']['token'],
        secret: omniauth['credentials']['secret']
    )
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end

  protected

  def extract_omniauth_data(omniauth)
    %W(email name first_name last_name location phone).each do |attr|
      self[attr] = omniauth['info'][attr] if self[attr].blank?
    end

    self.urls ||= {}
    self.urls.reverse_merge!(omniauth['info']['urls'].presence || {})
  end

  def set_default_watcher_status
    self.watcher_status = "none" if self.watcher_status.blank?
  end

  def update_watcher_reports
    return unless self.watcher_status_changed?

    if self.watcher_status == "approved"
      self.watcher_reports.each {|r| r.save! }
    elsif self.watcher_status == "rejected"
      self.watcher_reports.update_all(status: "rejected")
    elsif self.watcher_status == "problem"
      self.watcher_reports.update_all(status: "problem")
    elsif self.watcher_status == "blocked"
      self.watcher_reports.update_all(status: "blocked")
    end
  end
end
# == Schema Information
#
# Table name: users
#
#  id                     :integer         not null, primary key
#  email                  :string(255)     default(""), not null
#  encrypted_password     :string(128)     default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer         default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  failed_attempts        :integer         default(0)
#  unlock_token           :string(255)
#  locked_at              :datetime
#  created_at             :datetime
#  updated_at             :datetime
#  role                   :string(255)
#  watcher_status         :string(255)
#  organization_id        :integer
#  is_watcher             :boolean
#  name                   :string(255)
#  first_name             :string(255)
#  last_name              :string(255)
#  location               :string(255)
#  phone                  :string(255)
#  urls                   :text
#  birth_date             :date
#  unconfirmed_email      :string(255)
#
# Indexes
#
#  index_users_on_confirmation_token             (confirmation_token) UNIQUE
#  index_users_on_email                          (email) UNIQUE
#  index_users_on_is_watcher_and_watcher_status  (is_watcher,watcher_status)
#  index_users_on_organization_id                (organization_id)
#  index_users_on_reset_password_token           (reset_password_token) UNIQUE
#  index_users_on_unlock_token                   (unlock_token) UNIQUE
#

