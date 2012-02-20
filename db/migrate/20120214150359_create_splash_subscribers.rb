class CreateSplashSubscribers < ActiveRecord::Migration
  def self.up
    create_table :splash_subscribers, :force => true do |t|
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :splash_subscribers
  end
end