class AddIsDublToUserMessages < ActiveRecord::Migration
  def change
    add_column :user_messages, :is_dubl, :boolean, default: false
  end
end
