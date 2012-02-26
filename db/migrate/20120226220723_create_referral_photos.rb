class CreateReferralPhotos < ActiveRecord::Migration
  def up
    create_table :referral_photos, focrce: true do |t|
      t.integer :watcher_referral_id
      t.integer :media_item_id

      t.string :image

      t.datetime :timestamp

      t.timestamps
    end

    add_index :referral_photos, :watcher_referral_id
  end

  def down
    remove_index :referral_photos, :watcher_referral_id
    drop_table :referral_photos
  end
end
