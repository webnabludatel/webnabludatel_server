class AddImageToWatcherReferals < ActiveRecord::Migration
  def change
    add_column :watcher_referals, :image, :string
  end
end
