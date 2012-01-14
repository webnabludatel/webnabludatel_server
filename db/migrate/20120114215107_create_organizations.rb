class CreateOrganizations < ActiveRecord::Migration
  def up
    create_table :organizations, :force => true do |t|
      t.string :title
      t.string :kind

      t.timestamps
    end
  end

  def down
    drop_table :organizations
  end
end
