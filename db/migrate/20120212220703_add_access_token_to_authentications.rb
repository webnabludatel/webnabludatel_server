class AddAccessTokenToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :token, :string
    add_column :authentications, :secret, :string
  end
end
