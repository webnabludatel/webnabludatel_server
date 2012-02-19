class AddWatcherChecklistItemIdToWatcherReports < ActiveRecord::Migration
  def change
    add_column :watcher_reports, :watcher_checklist_item_id, :integer
    add_index :watcher_reports, :watcher_checklist_item_id
  end
end
