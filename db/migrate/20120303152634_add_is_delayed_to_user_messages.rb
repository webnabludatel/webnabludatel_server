class AddIsDelayedToUserMessages < ActiveRecord::Migration
  def change
    add_column :user_messages, :is_delayed, :boolean, default: false
  end
end
