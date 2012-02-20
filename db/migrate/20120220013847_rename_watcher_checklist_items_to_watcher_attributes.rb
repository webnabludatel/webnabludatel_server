class RenameWatcherChecklistItemsToWatcherAttributes < ActiveRecord::Migration
  def change
    rename_table :watcher_checklist_items, :watcher_attributes
  end
end
