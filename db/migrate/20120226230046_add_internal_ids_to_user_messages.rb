class AddInternalIdsToUserMessages < ActiveRecord::Migration
  def change
    add_column :user_messages, :internal_id, :string
    add_column :user_messages, :polling_place_internal_id, :string
  end
end
