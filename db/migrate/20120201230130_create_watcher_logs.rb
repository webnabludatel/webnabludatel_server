class CreateWatcherLogs < ActiveRecord::Migration
  def up
    create_table :watcher_logs, force: true do |t|
      t.string :key
      t.string :value
      t.timestamp :recorded_at

      t.boolean :is_violation

      t.integer :user_id
      t.integer :comission_id
      t.integer :device_message_id

      t.string :image
      t.string :video_path

      t.string :status

      t.timestamps
    end

    add_index :watcher_logs, :comission_id
    add_index :watcher_logs, :device_message_id
    add_index :watcher_logs, :user_id
  end

  def down
    remove_index :watcher_logs, :comission_id
    remove_index :watcher_logs, :device_message_id
    remove_index :watcher_logs, :user_id

    drop_table :watcher_logs
  end
end
