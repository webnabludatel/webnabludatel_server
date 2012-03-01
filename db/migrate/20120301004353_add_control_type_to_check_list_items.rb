class AddControlTypeToCheckListItems < ActiveRecord::Migration
  def change
    add_column :check_list_items, :control_type, :integer
  end
end
