class RenameWatcherLogsToWatcherReports < ActiveRecord::Migration
  def change
    rename_table :watcher_logs, :watcher_reports
  end
end
