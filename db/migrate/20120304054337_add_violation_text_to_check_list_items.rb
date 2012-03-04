class AddViolationTextToCheckListItems < ActiveRecord::Migration
  def change
    add_column :check_list_items, :violation_text, :text
  end
end
