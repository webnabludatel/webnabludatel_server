class AddIsSystemToCommissions < ActiveRecord::Migration
  def change
    add_column :commissions, :is_system, :boolean, default: false
  end
end
