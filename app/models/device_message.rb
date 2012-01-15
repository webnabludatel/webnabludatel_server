# encoding: utf-8

class DeviceMessage < ActiveRecord::Base
  belongs_to :user

  attr_accessible :message
end