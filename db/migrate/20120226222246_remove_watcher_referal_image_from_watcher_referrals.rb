class RemoveWatcherReferalImageFromWatcherReferrals < ActiveRecord::Migration
  def up
    remove_column :watcher_referrals, :watcher_referal_image
  end

  def down
    add_column :watcher_referrals, :watcher_referral_image, :string
  end
end
