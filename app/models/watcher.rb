# encoding: utf-8

class Watcher < ActiveRecord::Base
  belongs_to :organization

  has_many :device_messages, dependent: :destroy
  has_many :refferals, class_name: "WatcherRefferal", dependent: :destroy

  STATES = [:pending, :approved, :rejected, :problem, :none]

  validates :states, inclusion: { in: STATES }

  attr_accessible :name, :comment
end