# encoding: utf-8

class DeviceMessage < ActiveRecord::Base
  belongs_to :watcher

  attr_accessible :message
end