class CreateRegions < ActiveRecord::Migration
  def up
    create_table :regions, force: true do |t|
      t.string :name
      t.string :external_id

      t.timestamps
    end
  end

  def down
    drop_table :regions
  end
end
