require 'rubygems'
require 'bundler'
Bundler.setup(:default, :test)

require 'rspec'
require File.join(File.dirname(__FILE__), '..', 'lib', 'failurous')