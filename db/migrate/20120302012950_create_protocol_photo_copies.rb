class CreateProtocolPhotoCopies < ActiveRecord::Migration
  def up
    create_table :protocol_photo_copies, force: true do |t|
      t.integer :user_location_id
      t.integer :media_item_id

      t.string :image

      t.datetime :timestamp

      t.timestamps
    end

    add_index :protocol_photo_copies, :user_location_id
  end

  def down
    remove_index :protocol_photo_copies, :user_location_id
    drop_table :protocol_photo_copies
  end
end
