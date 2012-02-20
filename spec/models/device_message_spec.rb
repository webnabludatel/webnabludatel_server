require 'spec_helper'

describe DeviceMessage do
  context "with sending messages" do
    before(:each) do
      WatcherAttribute.delete_all
      WatcherAttribute.create name: "k", hi_value: "v"
    end

    it "should create watcher report if there is new message" do
      user = Fabricate(:user, watcher_status: "pending")
      location = Fabricate.build(:user_location)
      location.user = user
      location.save

      device_message = DeviceMessage.new(message: {"timestamp" => Time.now.to_i, "key" => "k", "value" => "v" })
      device_message.user = user
      device_message.save
      device_message.reload

      watcher_report = device_message.watcher_report
      watcher_report.should be
      watcher_report.key.should == "k"
      watcher_report.value.should == "v"
    end

    it "should update watcher report if updating existent message" do
      user = Fabricate(:user, watcher_status: "pending")
      location = Fabricate.build(:user_location)
      location.user = user
      location.save

      device_message = DeviceMessage.new(message: {"timestamp" => Time.now.to_i, "key" => "k", "value" => "v" })
      device_message.user = user
      device_message.save

      device_message.reload

      report_id = device_message.watcher_report.id

      WatcherAttribute.create name: "k1", hi_value: "v1"

      device_message.message["key"] = "k1"
      device_message.message["value"] = "v1"
      device_message.save!

      device_message.reload

      watcher_report = device_message.watcher_report
      watcher_report.should be
      watcher_report.id.should == report_id
      watcher_report.key.should == "k1"
      watcher_report.value.should == "v1"
    end
  end

end
