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
  has_many :user_messages, dependent: :destroy
  has_one :referral, class_name: "WatcherReferral", dependent: :destroy
  has_many :locations, class_name: "UserLocation", dependent: :destroy, order: :created_at
  has_many :commissions, through: :locations
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

  # TODO: Maybe we need to cache it in DB. Change order.
  def current_location
    @current_location ||= locations.order("created_at DESC").first
  end

  # TODO: Maybe we need to cache it in DB
  def current_commission
    @current_commission ||= current_location.try(:commission)
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
