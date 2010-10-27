require 'spec_helper'
require 'net/http'
require 'json'

describe Failurous::FailNotifier do
  it "should be defined when 'failurous' has been required" do
    defined?(Failurous::FailNotifier).should == "constant"
  end
  
  before(:each) do
    Failurous::Config.api_key = "123"
    @http = Failurous::FailNotifier.http = mock()
    @logger = Failurous::Config.logger = mock()
    @notification = Failurous::FailNotification.new("My own notification")
  end
  
  it "should post the notification as JSON to given server address and port" do
    @http.should_receive(:post).with("/api/projects/123/fails", @notification.attributes.to_json)
    Failurous::FailNotifier.send(@notification)
  end
  
  it "should not fail when posting the fail fails - instead, should log the error as warning" do
    @http.should_receive(:post).and_raise(RuntimeError)
    @logger.should_receive(:warn)
    lambda { Failurous::FailNotifier.send(@notification) }.should_not raise_error
  end
end