# encoding: utf-8

class Authentication < ActiveRecord::Base
  belongs_to :user

  validates :provider, :uid, presence: true
  validates :provider, uniqueness: {scope: :user_id}

  def to_s
    "#{provider}(#{uid})"
  end
end
