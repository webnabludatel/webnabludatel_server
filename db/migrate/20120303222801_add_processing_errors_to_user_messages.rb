class AddProcessingErrorsToUserMessages < ActiveRecord::Migration
  def change
    add_column :user_messages, :processing_errors, :text
  end
end
