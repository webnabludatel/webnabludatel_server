class AddWatcherReportIdToUserMessages < ActiveRecord::Migration
  def change
    add_column :user_messages, :watcher_report_id, :integer
    # TODO: We don't create index here because we actually don't use this relation.
  end
end
