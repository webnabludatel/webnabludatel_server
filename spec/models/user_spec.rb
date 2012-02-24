require 'spec_helper'

describe User do
  context "with default values" do
    it "should have none watcher status after initialize" do
      user = Fabricate.build(:user)
      user.watcher_status.none?.should be_true
    end
  end

  context "with locations" do
    it "current_location should return last added location" do
      user = Fabricate(:user)
      first_location = Fabricate(:user_location, :user => user)
      second_location = Fabricate(:user_location, :user => user)

      user.current_location.should == second_location
    end

    it "current_commission should return commission from last location" do
      user = Fabricate(:user)
      first_location = Fabricate(:user_location, :user => user)
      second_location = Fabricate(:user_location, :user => user)

      user.current_commission.should == second_location.commission
    end
  end
end
