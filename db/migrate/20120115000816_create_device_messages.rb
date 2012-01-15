class CreateDeviceMessages < ActiveRecord::Migration
  def up
    create_table :device_messages, :force => true do |t|
      t.text :message
      t.integer :user_id

      t.timestamps
    end

    add_index :device_messages, :user_id
  end

  def down
    remove_index :device_messages, :user_id

    drop_table :device_messages
  end
end
