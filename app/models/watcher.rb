class Watcher < ActiveRecord::Base
  belongs_to :organization

  STATES = [:pending, :approved, :rejected, :none]

  validates :states, :inclusion => { :in => STATES }
end