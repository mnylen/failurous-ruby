require 'rubygems'
require 'bundler'
Bundler.setup(:default, :test)

require 'rspec'
require File.join(File.dirname(__FILE__), '..', 'lib', 'failurous')

Dir.glob(File.join(File.dirname(__FILE__), 'support', 'matchers', '*')) { |f| require f }

RSpec.configure do |config|
  
end