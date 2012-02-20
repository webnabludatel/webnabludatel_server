class AddKindToDeviceMessages < ActiveRecord::Migration
  def change
    change_table :device_messages do |t|
      t.string :kind, :null => false, :default => 'message'
      t.string :device_id
      t.rename :message, :payload
      t.references :media_item
      t.references :user_message
    end

    add_index :device_messages, :media_item_id
    add_index :device_messages, :user_message_id
  end
end
