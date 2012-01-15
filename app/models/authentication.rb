class Authentication < ActiveRecord::Base
  belongs_to :user

  validates_uniqueness_of :provider, scope: :user_id
end
