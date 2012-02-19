class CreateWatcherChecklistItems < ActiveRecord::Migration
  def up
    create_table :watcher_checklist_items, force: true do |t|
      t.string :name
      t.string :title

      t.integer :order

      t.string :lo_value
      t.string :hi_value

      t.string :lo_text
      t.string :hi_text

      t.string :ancestry

      t.timestamps
    end
  end

  def down
    drop_table :watcher_checklists
  end
end
