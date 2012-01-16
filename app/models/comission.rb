# encoding: utf-8

class Comission < ActiveRecord::Base
  has_many :user_locations, :dependent => :destroy
  has_many :users, :through => :user_locations

  # TODO: add validations

  geocoded_by :address
  after_validation :geocode
end