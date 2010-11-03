require 'spec_helper'

describe Failurous do
  after(:each) do
    Failurous::FailNotifier.notifier = nil
  end
  
  describe "configuring" do
    it "should configure an instance of FailNotifier to FailNotifier.notifier" do
      lambda {
        do_configure 
      }.should change { Failurous::FailNotifier.notifier.nil? }.from(true).to(false)
    end
  end
  
  describe "notifying" do
    it "should raise RuntimeError if the notifier isn't configured" do
      lambda { Failurous.notify("test") }.should raise_exception(RuntimeError)
    end
    
    it "should call #notify_with_caller on the configured FailNotifier instance" do
      do_configure
      Failurous::FailNotifier.notifier.should_receive(:notify_with_caller)
      Failurous.notify("Test")
    end
  end
  
  
  def do_configure
    Failurous.configure do |config|
      config.server_name = "localhost"
      config.server_port = 3000
      config.api_key     = "api key"
    end
  end
end