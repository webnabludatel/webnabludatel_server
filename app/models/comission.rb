class Comission < ActiveRecord::Base
  # TODO: add validations

  geocoded_by :address
  after_validation :geocode
end