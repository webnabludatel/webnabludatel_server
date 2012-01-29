class CreateMessages < ActiveRecord::Migration
  def up
    create_table :messages, :force => true do |t|
      t.text :body
      t.string :status
      t.integer :user_id

      t.timestamps
    end

    add_index :messages, :user_id
  end

  def down
    remove_index :messages, :user_id

    drop_table :messages
  end
end
