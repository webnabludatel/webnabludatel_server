class RenameComissionToCommission < ActiveRecord::Migration
  def change
    rename_table :comissions, :commissions

    rename_column :watcher_reports, :comission_id, :commission_id
    rename_column :user_locations, :comission_id, :commission_id
  end
end
