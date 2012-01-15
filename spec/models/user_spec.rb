require 'spec_helper'

describe User do
  context "with default values" do
    it "should have none watcher status after initialize" do
      user = Fabricate.build(:user)
      user.watcher_status.none?.should be_true
    end
  end
end
