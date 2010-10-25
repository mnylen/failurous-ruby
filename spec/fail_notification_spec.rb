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
  
  
  describe "add_field" do
    before(:each) do
      @notification = Failurous::FailNotification.new
    end
    
    it "should create section" do
      @notification.add_field(:summary, :type, "NoMethodError")
      @notification.should have_section(:summary)
    end
    
    it "should not create a new section if the section already exists" do
      2.times do
        @notification.add_field(:summary, :type, "NoMethodError")
      end
      
      section_count(@notification).should == 1
    end
    
    it "should add the field to the section" do
      @notification.add_field(:summary, :type, "NoMethodError")
      @notification.should have_field(:summary, :type).with_value("NoMethodError")
    end
    
    it "should replace previous field with the same name" do
      @notification.add_field(:summary, :type, "NoMethodError")
      @notification.add_field(:summary, :type, "RuntimeError")
      
      field_count(@notification, :summary).should == 1
      @notification.should have_field(:summary, :type).with_value("RuntimeError")
    end
    
    it "should return self" do
      @notification.add_field(:summary, :type, "NoMethodError").should == @notification
    end
  end
  
  private
  
    def section_count(notification)
      notification.attributes[:data].size
    end
    
    def field_count(notification, section_name)
      section = notification.attributes[:data].detect { |section| section[0] == section_name }
      section ? section[1].size : 0
    end
end
