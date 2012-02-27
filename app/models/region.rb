# encoding: utf-8

class Region < ActiveRecord::Base
  has_many :commissions, dependent: :destroy
end