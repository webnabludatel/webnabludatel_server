# encoding: utf-8

class DeviceMessage < ActiveRecord::Base
  belongs_to :user

  has_many :watcher_reports, dependent: :destroy

  serialize :message

  attr_accessible :message
end