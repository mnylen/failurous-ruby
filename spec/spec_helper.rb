require 'rubygems'
require 'bundler'
Bundler.setup(:default, :test)

require 'rspec'
require File.join(File.dirname(__FILE__), '..', 'lib', 'failurous')

Dir.glob(File.join(File.dirname(__FILE__), 'support', 'matchers', '*')) { |f| require f }


module FailurousSpecHelpers
  def mock_exception(type = nil, message = nil, backtrace = nil)
    type      ||= RuntimeError
    message   ||= "Lorem ipsum"
    backtrace ||= ['location0', 'location1', 'location2']
    
    exception = type.new(message)
    exception.stub!(:backtrace).and_return(backtrace)
    
    exception
  end
end

RSpec.configure do |config|
  include FailurousSpecHelpers
end

