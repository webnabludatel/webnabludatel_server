class AddChairmanAndSecretaryToUserLocations < ActiveRecord::Migration
  def change
    add_column :user_locations, :chairman, :string
    add_column :user_locations, :secretary, :string
  end
end
