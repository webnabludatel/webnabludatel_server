class AddExternalIdToUserLocations < ActiveRecord::Migration
  def change
    add_column :user_locations, :external_id, :string
  end
end
