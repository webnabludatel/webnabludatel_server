class CreateSosMessagePhotos < ActiveRecord::Migration
  def up
    create_table :sos_message_photos, force: true do |t|
      t.integer :sos_message_id

      t.string :image

      t.datetime :timestamp

      t.integer :media_item_id

      t.timestamps
    end

    add_index :sos_message_photos, :sos_message_id
  end

  def down
    remove_index :sos_message_photos, :sos_message_id
    drop_table :sos_message_photos
  end
end
