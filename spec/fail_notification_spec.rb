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
      
      context "ambiguous field placement" do
        it "should raise ArgumentError if both :above and :below is specified" do
          lambda {
            @notification.add_field(:summary, :type, "RuntimeError", {}, {:below => :a, :above => :b})
          }.should raise_error(ArgumentError)
        end
        
        it "should not add the field" do
          lambda {
            @notification.add_field(:summary, :type, "RuntimeError", {}, {:below => :a, :above => :b}) rescue nil
          }.should_not change { field_count(@notification, :summary) }
        end
      end
    end
  end
  
  describe "fill_from_exception" do
    before(:each) do
      @error = RuntimeError.new("tl;dr")
      @error.stub!(:backtrace).and_return(['a', 'b', 'c'])
      
      @notification = Failurous::FailNotification.new()
      @notification.fill_from_exception(@error)
    end
    
    it "should set the title as 'type: message'" do
      @notification.title.should == "RuntimeError: tl;dr"
    end
    
    it "should set the location as the topmost line in backtrace" do
      @notification.location.should == "a"
    end
    
    it "should use location in checksum" do
      @notification.use_location_in_checksum.should == true
    end
    
    it "should not use title in checksum" do
      @notification.use_title_in_checksum.should == false
    end
    
    it "should not override previously set title" do
      @notification = Failurous::FailNotification.new()
      @notification.title = "asdf"
      @notification.fill_from_exception(@error)
      @notification.title.should == "asdf"
    end
    
    it "should not override setting for using title in checksum" do
      @notification = Failurous::FailNotification.new()
      @notification.use_title_in_checksum = true
      @notification.fill_from_exception(@error)
      @notification.use_title_in_checksum.should == true
    end
    
    it "should not override previously set location" do
      @notification = Failurous::FailNotification.new
      @notification.location = "my own location"
      @notification.fill_from_exception(@error)
      @notification.location.should == "my own location"  
    end
    
    it "should create section 'Summary'" do
      @notification.should have_section(:summary)
    end
    
    context "section summary" do
      subject { @notification }
      
      it { should have_field(:summary, :type).with_value("RuntimeError").with_options(:use_in_checksum => true) }
      
      it { should have_field(:summary, :message).with_value("tl;dr").with_options(:use_in_checksum => false) }
      
      it { should have_field(:summary, :topmost_line_in_backtrace).with_value("a").with_options(:use_in_checksum => true) }  
    end 
    
    
    it "should create section 'Details'" do
      @notification.should have_section(:details)
    end
    
    context "details" do
      subject { @notification }
      
      it { should have_field(:details, :full_backtrace).with_value(@error.backtrace.join('\n')).with_options(:use_in_checksum => false) }
    end
  end
  
  
  describe "initializer" do
    it "should use the title given as first parameter" do
      Failurous::FailNotification.new("My title").title.should == "My title"
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
