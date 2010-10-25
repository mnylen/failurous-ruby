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
  
  
  describe "location" do
    before(:each) do
      @notification = Failurous::FailNotification.new
    end
  
  
    it "should be the caller of Failurous::FailNotification.new" do
      @notification.location.should == "#{__FILE__}:26:in `new'"
    end
  
    
    it "should be overrideable by location=" do
      @notification.location = "custom location"
      @notification.location.should == "custom location"
    end
    
    
    it "should not be set until location is set by location=" do
      lambda { @notification.location = "custom location " }.should change(@notification, :location_set?).from(false).to(true)
    end
  end
end
