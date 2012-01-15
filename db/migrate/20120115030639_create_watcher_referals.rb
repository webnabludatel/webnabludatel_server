class CreateWatcherReferals < ActiveRecord::Migration
  def up
    create_table :watcher_referals, :force => true do |t|
      t.integer :user_id
      t.string :status

      t.string :watcher_referal_image

      t.text :comment

      t.timestamps
    end

    add_index :watcher_referals, :user_id
    add_index :watcher_referals, :status
  end

  def down
    remove_index :watcher_referals, :user_id
    remove_index :watcher_referals, :status

    drop_table :watcher_referals
  end
end
