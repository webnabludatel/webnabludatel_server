class AddStatusToComissions < ActiveRecord::Migration
  def change
    add_column :comissions, :status, :string
  end
end
