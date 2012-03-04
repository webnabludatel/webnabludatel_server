class AddCommentToUserLocation < ActiveRecord::Migration
  def change
    add_column :user_locations, :comment, :text
  end
end
