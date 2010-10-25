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
    
    
    context "field placement :below" do
      before(:each) do
        @notification.add_field(:summary, :message, "Lorem ipsum")
        @notification.add_field(:summary, :top_of_backtrace, "xyz.rb:39:in `xyz'")
      end
      
      it "should add the field below the specified field" do
        @notification.add_field(:summary, :type, "NoMethodError", {}, :below => :message)
        @notification.should have_field(:summary, :type).below(:message)
      end
      
      it "should append field to end of the section if the specified field does not exist" do
        @notification.add_field(:summary, :type, "NoMethodError", {}, :below => :my_imaginary_field)  
        @notification.should have_field(:summary, :type).as_last_field
      end
      
      it "should replace already existing field and move it" do
        @notification.add_field(:summary, :type, "NoMethodError")
        @notification.should have_field(:summary, :type).as_last_field
        
        @notification.add_field(:summary, :type, "RuntimeError", {}, :below => :message)
        @notification.should have_field(:summary, :type).below(:message)
        field_count(@notification, :summary).should == 3
      end
    end
    
    
    context "field placement :above" do
      before(:each) do
        @notification.add_field(:summary, :message, "Lorem ipsum")
      end
      
      it "should add the field above the specified field" do
        @notification.add_field(:summary, :type, "NoMethodError", {}, :above => :message)
        @notification.should have_field(:summary, :type).above(:message)
      end
      
      it "should append field to end of the section if the specified field does not exist" do
        @notification.add_field(:summary, :type, "NoMethodError", {}, :above => :my_imaginary_field)  
        @notification.should have_field(:summary, :type).as_last_field
      end
      
      
      it "should replace already existing field and move it" do
        @notification.add_field(:summary, :type, "NoMethodError")
        @notification.should have_field(:summary, :type).as_last_field
        
        @notification.add_field(:summary, :type, "RuntimeError", {}, :above => :message)
        @notification.should have_field(:summary, :type).with_value("RuntimeError").above(:message)
        field_count(@notification, :summary).should == 2
      end
      
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
