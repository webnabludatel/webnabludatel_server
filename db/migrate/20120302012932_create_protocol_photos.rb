class CreateProtocolPhotos < ActiveRecord::Migration
  def up
    create_table :protocol_photos, force: true do |t|
      t.integer :user_location_id
      t.integer :media_item_id

      t.string :image

      t.datetime :timestamp

      t.timestamps
    end

    add_index :protocol_photos, :user_location_id
  end

  def down
    remove_index :protocol_photos, :user_location_id
    drop_table :protocol_photos
  end
end
