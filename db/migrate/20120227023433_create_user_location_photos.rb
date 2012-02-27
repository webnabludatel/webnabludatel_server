class CreateUserLocationPhotos < ActiveRecord::Migration
  def up
    create_table :user_location_photos, focrce: true do |t|
      t.integer :user_location_id
      t.integer :media_item_id

      t.string :image

      t.datetime :timestamp

      t.timestamps
    end

    add_index :user_location_photos, :user_location_id
  end

  def down
    remove_index :user_location_photos, :user_location_id
    drop_table :user_location_photos
  end
end
