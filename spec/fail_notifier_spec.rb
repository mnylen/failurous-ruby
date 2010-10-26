require 'spec_helper'

describe Failurous::FailNotifier do
  it "should be defined when 'failurous' has been required" do
    defined?(Failurous::FailNotifier).should == "constant"
  end
end