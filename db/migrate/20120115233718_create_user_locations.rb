class CreateUserLocations < ActiveRecord::Migration
  def up
    create_table :user_locations, :force => true do |t|
      t.integer :user_id
      t.integer :comission_id

      t.float :latitude
      t.float :longitude

      t.string :status

      t.timestamps
    end

    add_index :user_locations, [:user_id, :comission_id]
  end

  def down
    remove_index :user_locations, [:user_id, :comission_id]

    drop_table :user_locations
  end
end
