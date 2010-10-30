require 'spec_helper'
require 'net/http'
require 'json'

describe Failurous::FailNotifier do
  it "should be defined when 'failurous' has been required" do
    defined?(Failurous::FailNotifier).should == "constant"
  end
  
  before(:each) do
    @http = mock()
    @http.stub!(:post)
    @config = Failurous::Config.new
    @config.api_key = "123"
    @logger = @config.logger = mock()
    @notifier = Failurous::FailNotifier.new(@config, @http)
  end
  
  
  describe "#notify" do
    before(:each) do
      @notification = Failurous::FailNotification.new("My own notification")  
    end
    
    it "should post the notification using the given HTTP instance" do
      @http.should_receive(:post)
      @notifier.notify(@notification)
    end
  
    it "should not fail when posting the fail fails - instead, should log the error as warning" do
      @http.should_receive(:post).and_raise(RuntimeError)
      @logger.should_receive(:warn)
      lambda { @notifier.notify(@notification) }.should_not raise_error
    end
    
    it "should return the notification it sent" do
      @notifier.notify(@notification).should == @notification
    end
    
    context "shorthands" do
      it "when given string as it's only argument, should send a notification using the string as title" do
        notification = @notifier.notify("My custom message")
        notification.title.should == "My custom message"
      end
      
      it "when given exception as it's only argument, should send a notification built from the exception" do
        notification = @notifier.notify(mock_exception(RuntimeError))
        notification.should have_section(:summary)
      end
      
      it "when given string and exception as arguments, should send a notification built from the exception, using the string as title" do
        notification = @notifier.notify("My custom title", mock_exception(RuntimeError))
        notification.title.should == "My custom title"
        notification.should have_section(:summary)
      end
    end
    
  end
  
end