class AddStatusToWatcherReportPhotos < ActiveRecord::Migration
  def change
    add_column :watcher_report_photos, :status, :string, :null => false, :default => 'pending'
  end
end
