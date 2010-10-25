require 'spec_helper'

describe Failurous::FailNotification do
  it "should be available when 'failurous' has been required" do
    defined?(Failurous::FailNotification).should == "constant"
  end
  
  describe "title" do
    before(:each) do
      @notification = Failurous::FailNotification.new("Lorem ipsum")
    end
    
    it "should be the one given in initializer" do
      @notification.title.should == "Lorem ipsum"
    end
    
    it "should be overridable by title=" do
      @notification.title = "Dolor sit amet"
      @notification.title.should == "Dolor sit amet"
    end
  end
end
