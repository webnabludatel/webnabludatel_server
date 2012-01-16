require 'spec_helper'

describe User do
  context "with default values" do
    it "should have pending status after initialize" do
      user_location = Fabricate.build(:user_location)
      user_location.status.pending?.should be_true
    end
  end
end
