# encoding: utf-8

class SosMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_message

  has_many :photos, class_name: "SosMessagePhoto", dependent: :destroy
end