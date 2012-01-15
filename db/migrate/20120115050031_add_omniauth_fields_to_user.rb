class AddOmniauthFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :location, :string
    add_column :users, :phone, :string
    add_column :users, :urls, :text
    add_column :users, :birth_date, :date
  end
end
