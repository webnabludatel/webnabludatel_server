class AddUserLocationIdToSosMessages < ActiveRecord::Migration
  def change
    add_column :sos_messages, :user_location_id, :integer
    add_index :sos_messages, :user_location_id
  end
end
