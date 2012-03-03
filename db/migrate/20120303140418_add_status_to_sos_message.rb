class AddStatusToSosMessage < ActiveRecord::Migration
  def change
    add_column :sos_messages, :status, :string
  end
end
