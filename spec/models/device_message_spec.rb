require 'spec_helper'

describe DeviceMessage do
  context "with sending 'post' messages" do
    it "should create watcher report if there is new message" do
      user = Fabricate(:user, watcher_status: "pending")
      location = Fabricate.build(:user_location)
      location.user = user
      location.save

      device_message = DeviceMessage.new(message: { "MSG_TYPE" => "post", "TIMESTAMP" => Time.now.to_i, "PAYLOAD" => { "key" => "value" } })
      device_message.user = user
      device_message.save
      device_message.reload

      watcher_report = device_message.watcher_report
      watcher_report.should be
      watcher_report.key.should == "key"
      watcher_report.value.should == "value"
    end

    it "should update watcher report if updating existent message" do
      user = Fabricate(:user, watcher_status: "pending")
      location = Fabricate.build(:user_location)
      location.user = user
      location.save

      device_message = DeviceMessage.new(message: { "MSG_TYPE" => "post", "TIMESTAMP" => Time.now.to_i, "PAYLOAD" => { "key" => "value" } })
      device_message.user = user
      device_message.save

      device_message.reload

      report_id = device_message.watcher_report.id

      device_message.message["PAYLOAD"] = { "key" => "value1" }
      device_message.save!

      device_message.reload

      watcher_report = device_message.watcher_report
      watcher_report.should be
      watcher_report.id.should == report_id
      watcher_report.key.should == "key"
      watcher_report.value.should == "value1"
    end
  end

end
