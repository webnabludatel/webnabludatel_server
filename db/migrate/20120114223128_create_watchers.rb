class CreateWatchers < ActiveRecord::Migration
  def up
    create_table :watchers, :force => true do |t|
      t.string :name
      t.string :kind
      t.string :state

      t.text :comment

      t.integer :organization_id

      t.timestamps
    end

    add_index :watchers, :organization_id
  end

  def down
    remove_index :watchers, :organization_id

    drop_table :watchers
  end
end
