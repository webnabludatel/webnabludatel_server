class ChangeUserMessageValueToText < ActiveRecord::Migration
  def up
    change_column :user_messages, :value, :text
  end

  def down
    change_column :user_messages, :value, :string
  end
end
