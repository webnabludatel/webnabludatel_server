class CreateSneak < ActiveRecord::Migration
  def change
    create_table :flags do |t|
      t.string :sneak_type
      t.integer :sneak_id
      t.string :flaggeable_type
      t.integer :flaggeable_id

      t.string :report_type

      t.timestamps
    end
  end

end

