class ChangeWatcherReportsRelations < ActiveRecord::Migration

  def change
    remove_index :watcher_reports, name: :index_watcher_logs_on_comission_id
    remove_index :watcher_reports, name: :index_watcher_logs_on_device_message_id
    remove_index :watcher_reports, name: :index_watcher_logs_on_user_id

    remove_column :watcher_reports, :commission_id
    remove_column :watcher_reports, :device_message_id

    add_column :watcher_reports, :user_location_id, :integer
    add_index :watcher_reports, :user_location_id

    rename_column :watcher_reports, :watcher_attribute_id, :check_list_id

    rename_column :watcher_reports, :recorded_at, :timestamp

    add_index :watcher_reports, :timestamp
    add_index :watcher_reports, :user_id

    add_column :watcher_reports, :latitude, :decimal, precision: 11, scale: 8
    add_column :watcher_reports,  :longitude, :decimal, precision: 11, scale: 8
  end

end
