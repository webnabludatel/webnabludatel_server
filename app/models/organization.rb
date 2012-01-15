class Organization < ActiveRecord::Base
  has_many :watchers, :dependent => :destroy

  validates :title, :presence => true, :uniqueness => true

  attr_accessible :title
end