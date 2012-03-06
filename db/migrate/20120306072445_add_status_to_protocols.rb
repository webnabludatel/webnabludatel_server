class AddStatusToProtocols < ActiveRecord::Migration
  def change
    add_column :protocol_photos, :status, :string, default: "pending"
    add_column :protocol_photo_copies, :status, :string, default: "pending"
  end
end
