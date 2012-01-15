class CreateDeviceMessages < ActiveRecord::Migration
  def up
    create_table :device_messages, :force => true do |t|
      t.text :message
      t.integer :watcher_id

      t.timestamps
    end

    add_index :device_messages, :watcher_id
  end

  def down
    remove_index :device_messages, :watcher_id

    drop_table :device_messages
  end
end
