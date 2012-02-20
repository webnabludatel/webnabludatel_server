# encoding: utf-8

class Organization < ActiveRecord::Base
  has_many :users, dependent: :destroy

  validates :title, presence: true, uniqueness: true

  attr_accessible :title
end
# == Schema Information
#
# Table name: organizations
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  kind       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

