class AddRegionIdToCommissions < ActiveRecord::Migration
  def change
    add_column :commissions, :region_id, :integer
    add_index :commissions, :region_id
  end
end
