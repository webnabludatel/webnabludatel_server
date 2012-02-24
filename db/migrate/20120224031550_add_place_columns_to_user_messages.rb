class AddPlaceColumnsToUserMessages < ActiveRecord::Migration
  def change
    add_column :user_messages, :polling_place_region, :string
    add_column :user_messages, :polling_place_id, :string
  end
end
