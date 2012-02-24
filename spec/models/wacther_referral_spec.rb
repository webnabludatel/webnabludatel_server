require 'spec_helper'

describe WatcherReferral do
  context "with default values" do
    it "should be in the pending status by default" do
      watcher_referral = Fabricate.build(:watcher_referral)
      watcher_referral.status.pending?.should be
    end
  end

  context "with changing status" do
    it "should be approved after approve!" do
      watcher_referral = Fabricate(:watcher_referral)
      comment = "Comment"
      watcher_referral.approve! comment

      watcher_referral.status.approved?.should be
      watcher_referral.comment.should == comment
    end

    it "should be rejected after reject!" do
      watcher_referral = Fabricate(:watcher_referral)
      comment = "Comment"
      watcher_referral.reject! comment

      watcher_referral.status.rejected?.should be
      watcher_referral.comment.should == comment
    end

    it "should be problem after problem!" do
      watcher_referral = Fabricate(:watcher_referral)
      comment = "Comment"
      watcher_referral.problem! comment

      watcher_referral.status.problem?.should be
      watcher_referral.comment.should == comment
    end

    it "should update user watcher status when referral status was changed" do
      user = Fabricate(:user)
      watcher_referral = Fabricate(:watcher_referral, :user => user)

      user.reload

      user.watcher_status.should == watcher_referral.status

      watcher_referral.status = "approved"
      watcher_referral.save

      user.reload

      user.watcher_status.should == watcher_referral.status
    end
  end
end
