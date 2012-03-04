class AddWatcherKindToUsers < ActiveRecord::Migration
  def change
    add_column :users, :watcher_kind, :string
  end
end
