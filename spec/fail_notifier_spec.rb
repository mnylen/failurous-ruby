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
      before(:each) do
        @config.custom_notification = MyFailNotification
      end
      
      after(:each) do
        @config.custom_notification = nil
      end
      
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
      
      it "when the last argument is an object, should build the notification using the details from the object" do
        @notifier.notify("My custom title", self).should have_section(:object)
        @notifier.notify("My custom title", mock_exception(RuntimeError), self).should have_section(:object)
        @notifier.notify("My custom title").should_not have_section(:object)
        @notifier.notify("My custom title", mock_exception(RuntimeError)).should_not have_section(:object)
      end
      
      it "should build the notification using the custom notification class, if specified" do
        @notifier.notify("My custom title").should be_a(MyFailNotification)
      end
    end
    
  end
  
end

class MyFailNotification < Failurous::FailNotification
  def fill_from_object(object)
    self.add_field(:object, :type, "Test")
  end
end