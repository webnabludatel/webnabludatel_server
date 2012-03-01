class AddIsProcessedToUserMessagesAndMediaItems < ActiveRecord::Migration
  def change
    add_column :user_messages, :is_processed, :boolean, default: false
    add_column :media_items, :is_processed, :boolean, default: false
  end
end
