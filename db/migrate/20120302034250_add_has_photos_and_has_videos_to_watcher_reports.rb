class AddHasPhotosAndHasVideosToWatcherReports < ActiveRecord::Migration
  def change
    add_column :watcher_reports, :has_photos, :boolean, default: false
    add_column :watcher_reports, :has_videos, :boolean, default: false
  end
end
