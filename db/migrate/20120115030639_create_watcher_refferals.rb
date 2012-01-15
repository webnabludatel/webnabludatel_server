class CreateWatcherRefferals < ActiveRecord::Migration
  def up
    create_table :watcher_refferals, :force => true do |t|
      t.integer :user_id
      t.string :status

      t.string :watcher_refferal_image

      t.text :comment

      t.timestamps
    end

    add_index :watcher_refferals, :user_id
    add_index :watcher_refferals, :status
  end

  def down
    remove_index :watcher_refferals, :user_id
    remove_index :watcher_refferals, :status

    drop_table :watcher_refferals
  end
end
