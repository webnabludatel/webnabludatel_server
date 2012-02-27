class AddDeletedToMediaItems < ActiveRecord::Migration
  def self.up
    add_column :media_items, :deleted, :boolean, :null => false, :default => true
    add_column :media_items, :user_id, :integer
    add_index :media_items, :user_id

    MediaItem.find_each {|i| i.update_attribute(:user_id, i.user_message.user_id)}
  end

  def self.down
    remove_column :media_items, :user_id
    remove_column :media_items, :deleted
  end
end
