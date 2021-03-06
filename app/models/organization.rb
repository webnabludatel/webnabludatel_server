# encoding: utf-8

class Organization < ActiveRecord::Base
  has_many :users, dependent: :destroy

  validates :title, presence: true, uniqueness: true

  attr_accessible :title
end
