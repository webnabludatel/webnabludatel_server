class CreateMediaItems < ActiveRecord::Migration
  def change
    create_table :media_items do |t|
      t.references :user_message

      t.string :url
      t.string :media_type
      t.timestamp :timestamp

      t.timestamps
    end

    add_index :media_items, :user_message_id
  end
end
