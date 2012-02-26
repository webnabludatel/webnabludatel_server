# encoding: utf-8

class ReferralPhoto < ActiveRecord::Base
  belongs_to :watcher_referral
  belongs_to :media_item

  mount_uploader :image, WatcherReferralImageUploader
end