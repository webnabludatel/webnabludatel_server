class CreateWatcherReportPhotos < ActiveRecord::Migration
  def up
    create_table :watcher_report_photos, force: true do |t|
      t.integer :watcher_report_id
      t.integer :media_item_id

      t.string :image
      t.datetime :timestamp

      t.timestamps
    end

    add_index :watcher_report_photos, :watcher_report_id
  end

  def down
    remove_index :watcher_report_photos, :watcher_report_id
    drop_table :watcher_report_photos
  end
end
