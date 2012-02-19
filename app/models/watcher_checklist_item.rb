class WatcherChecklistItem < ActiveRecord::Base
  has_many :watcher_reports, dependent: destroy

  has_ancestry
end