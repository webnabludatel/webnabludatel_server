class CreateSosMessages < ActiveRecord::Migration
  def up
    create_table :sos_messages, force: true do |t|
      t.text :body
      t.integer :user_id

      t.datetime :timestamp

      t.decimal :latitude, precision: 11, scale: 8
      t.decimal :longitude, precision: 11, scale: 8

      t.integer :user_message_id

      t.timestamps
    end

    add_index :sos_messages, :user_id
  end

  def down
    remove_index :sos_messages, :user_id
    drop_table :sos_messages
  end
end
