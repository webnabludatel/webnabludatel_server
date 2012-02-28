# encoding: utf-8

class CheckListItem < ActiveRecord::Base
  #has_many :watcher_reports, dependent: :destroy

  has_ancestry
end