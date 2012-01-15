class AddWatcherColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :watcher_status, :string
    add_column :users, :organization_id, :integer
    add_column :users, :is_watcher, :boolean

    add_index :users, :organization_id
    add_index :users, [:is_watcher, :watcher_status]
  end
end
