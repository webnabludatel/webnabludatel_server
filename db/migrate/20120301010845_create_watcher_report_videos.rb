class CreateWatcherReportVideos < ActiveRecord::Migration
  def up
    create_table :watcher_report_videos, force: true do |t|
      t.integer :watcher_report_id
      t.integer :media_item_id

      t.string :url
      t.datetime :timestamp

      t.timestamps
    end

    add_index :watcher_report_videos, :watcher_report_id
  end

  def down
    remove_index :watcher_report_videos, :watcher_report_id
    drop_table :watcher_report_videos
  end
end
