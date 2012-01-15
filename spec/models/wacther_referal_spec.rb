require 'spec_helper'

describe WatcherReferal do
  context "with default values" do
    it "should be in the pending status by default" do
      watcher_referal = Fabricate.build(:watcher_referal)
      watcher_referal.status.pending?.should be
    end
  end

  context "with changing status" do
    it "should be approved after approve!" do
      watcher_referal = Fabricate(:watcher_referal)
      comment = "Comment"
      watcher_referal.approve! comment

      watcher_referal.status.approved?.should be
      watcher_referal.comment.should == comment
    end

    it "should be rejected after reject!" do
      watcher_referal = Fabricate(:watcher_referal)
      comment = "Comment"
      watcher_referal.reject! comment

      watcher_referal.status.rejected?.should be
      watcher_referal.comment.should == comment
    end

    it "should be problem after problem!" do
      watcher_referal = Fabricate(:watcher_referal)
      comment = "Comment"
      watcher_referal.problem! comment

      watcher_referal.status.problem?.should be
      watcher_referal.comment.should == comment
    end
  end
end
