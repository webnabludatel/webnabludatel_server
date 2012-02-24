require 'spec_helper'

describe WatcherReport do
  it "should set watcher check list item when it wasn't set manually" do

  end

  it "should correctly set is_violation" do
    plist = WatcherAttribute.create name: "k", hi_value: "violation", lo_value: "ok"

    violation_watcher_report = WatcherReport.new key: "k", value: "violation"
    violation_watcher_report.watcher_attribute = plist
    violation_watcher_report.status = "manual_approved"
    violation_watcher_report.save!

    violation_watcher_report.is_violation?.should be

    ok_watcher_report = WatcherReport.new key: "k", value: "violat"
    ok_watcher_report.watcher_attribute = plist
    ok_watcher_report.status = "manual_approved"
    ok_watcher_report.save!

    ok_watcher_report.is_violation?.should_not be
  end

  context "updating user status" do
    before(:each) do
      WatcherAttribute.delete_all
      WatcherReport.delete_all
      DeviceMessage.delete_all
      Commission.delete_all
      UserLocation.delete_all
      User.delete_all

      WatcherAttribute.create name: "k", hi_value: "v"

      @user = Fabricate(:user, watcher_status: "pending")
      @location = Fabricate.build(:user_location)
      @location.user = @user
      @location.save

      @device_message = DeviceMessage.new(message: {"timestamp" => Time.now.to_i, "key" => "k", "value" => "v" })
      @device_message.user = @user
      @device_message.save
      @device_message.reload
      @watcher_report = @device_message.watcher_report
    end

    context "with pending" do
      it "set all user watcher reports to pending when user location is pending" do
        device_message = DeviceMessage.new(message: {"timestamp" => Time.now.to_i, "key" => "k", "value" => "v" })
        device_message.user = @user
        device_message.save!

        device_message.reload

        watcher_report = device_message.watcher_report

        watcher_report.should be
        watcher_report.status.pending?.should be
      end
    end

    context "with rejected" do
      it "should set all user watcher reports to rejected when user location is pending" do
        @user.watcher_status = "rejected"
        @user.save!

        @watcher_report.reload

        @watcher_report.status.rejected?.should be
      end
    end


    context "with blocked" do
      it "should set all user watcher reports to blocked when user location is pending" do
        @user.watcher_status = "blocked"
        @user.save!

        @watcher_report.reload

        @watcher_report.status.blocked?.should be
      end
    end

    context "with problem" do
      it "should set all user watcher reports to problem when user location is pending" do
        @user.watcher_status = "problem"
        @user.save!

        @watcher_report.reload

        @watcher_report.status.problem?.should be
      end
    end

    context "with approved" do
      it "should set all user watcher reports to approved when location is approved" do
        @location.status = "approved"
        @location.save!

        @user.watcher_status = "approved"
        @user.save!

        @watcher_report.reload

        @watcher_report.status.approved?.should be
      end
    end
  end

  context "updating user location status" do
    before(:each) do
      WatcherAttribute.delete_all
      WatcherReport.delete_all
      DeviceMessage.delete_all
      Commission.delete_all
      UserLocation.delete_all
      User.delete_all

      WatcherAttribute.create name: "k", hi_value: "v"

      @user = Fabricate(:user, watcher_status: "pending")
      @location = Fabricate.build(:user_location)
      @location.user = @user
      @location.save

      @device_message = @user.device_messages.create(message: {"timestamp" => Time.now.to_i, "key" => "k", "value" => "v" })
      @device_message.reload
      @watcher_report = @device_message.watcher_report
    end

    it "should set all user watcher reports at this location to rejected when location status changed to rejected" do
      @location.status = "rejected"
      @location.save!

      @watcher_report.reload

      @watcher_report.status.rejected?.should be
    end

    it "should set all user watcher reports at this location to suspicious when user status changed to problem" do
      @location.status = "suspicious"
      @location.save!

      @watcher_report.reload

      @watcher_report.status.location_suspicious?.should be
    end

    context "with approved" do
      it "should set all user watcher reports at this location to approved when user is approved" do
        @user.watcher_status = "approved"
        @user.save!

        @location.status = "approved"
        @location.save!

        @watcher_report.reload

        @watcher_report.status.approved?.should be
      end

      it "should set all user watcher reports at this location to approved when user is rejected" do
        @user.watcher_status = "rejected"
        @user.save!

        @location.status = "approved"
        @location.save!

        @watcher_report.reload

        @watcher_report.status.rejected?.should be
      end

      it "should set all user watcher reports at this location to approved when l user is blocked" do
        @user.watcher_status = "blocked"
        @user.save!

        @location.status = "approved"
        @location.save!

        @watcher_report.reload

        @watcher_report.status.blocked?.should be
      end

      it "should set all user watcher reports at this location to approved when user is problem" do
        @user.watcher_status = "problem"
        @user.save!

        @location.status = "approved"
        @location.save!

        @watcher_report.reload

        @watcher_report.status.problem?.should be
      end
    end
  end
end
