class AddUserLocationToUserMessages < ActiveRecord::Migration
  def change
    add_column :user_messages, :user_location_id, :integer
  end
end
