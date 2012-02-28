class FixCheckListItemColumnInWatcherReports < ActiveRecord::Migration

  def change
    rename_column :watcher_reports, :check_list_id, :check_list_item_id
  end

end
