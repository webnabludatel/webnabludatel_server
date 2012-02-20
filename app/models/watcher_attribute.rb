# encoding: utf-8

class WatcherAttribute < ActiveRecord::Base
  has_many :watcher_reports, dependent: :destroy

  has_ancestry
end
# == Schema Information
#
# Table name: watcher_attributes
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  title      :string(255)
#  order      :integer
#  lo_value   :string(255)
#  hi_value   :string(255)
#  lo_text    :string(255)
#  hi_text    :string(255)
#  ancestry   :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

