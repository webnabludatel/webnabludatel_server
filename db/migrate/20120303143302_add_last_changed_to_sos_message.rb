class AddLastChangedToSosMessage < ActiveRecord::Migration
  def change
    add_column :sos_messages, :last_changed_user_id, :integer
  end
end
