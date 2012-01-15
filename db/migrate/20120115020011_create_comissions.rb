class CreateComissions < ActiveRecord::Migration
  def up
    create_table :comissions, :force => true do |t|
      t.string :number
      t.float :latitude
      t.float :longitude

      t.string :kind

      t.text :address

      t.timestamps
    end
  end

  def down
    drop_table :comissions
  end
end
