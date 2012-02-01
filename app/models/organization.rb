# encoding: utf-8

class Organization < ActiveRecord::Base
  has_many :users, dependent: :destroy
  has_many :watcher_logs, dependent: :destroy

  validates :title, presence: true, uniqueness: true

  attr_accessible :title
end