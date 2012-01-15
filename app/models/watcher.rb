class Watcher < ActiveRecord::Base
  belongs_to :organization

  has_many :device_messages, :dependent => :destroy

  STATES = [:pending, :approved, :rejected, :none]

  validates :states, :inclusion => { :in => STATES }

  attr_accessible :name, :comment
end