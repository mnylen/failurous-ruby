require 'spec_helper'

describe Failurous::FailNotification do
  
  it "should be available when 'failurous' has been required" do
    defined?(Failurous::FailNotification).should == "constant"
  end
  
end