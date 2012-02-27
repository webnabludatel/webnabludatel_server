class AddPositionToRegions < ActiveRecord::Migration
  def change
    add_column :regions, :position, :integer
  end
end
