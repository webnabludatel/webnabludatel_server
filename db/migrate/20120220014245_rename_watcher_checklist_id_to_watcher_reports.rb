class RenameWatcherChecklistIdToWatcherReports < ActiveRecord::Migration
  def change
    rename_column :watcher_reports, :watcher_checklist_item_id, :watcher_attribute_id
  end
end
