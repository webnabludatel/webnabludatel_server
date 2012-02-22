class RenameWacherReferalsToWatcherReferrals < ActiveRecord::Migration
  def change
    rename_table :watcher_referals, :watcher_referrals
  end
end
