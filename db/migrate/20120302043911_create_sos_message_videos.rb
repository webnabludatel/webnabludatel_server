class CreateSosMessageVideos < ActiveRecord::Migration
  def up
    create_table :sos_message_videos, force: true do |t|
      t.integer :sos_message_id

      t.string :url

      t.datetime :timestamp

      t.integer :media_item_id

      t.timestamps
    end

    add_index :sos_message_videos, :sos_message_id
  end

  def down
    remove_index :sos_message_videos, :sos_message_id
    drop_table :sos_message_videos
  end
end
