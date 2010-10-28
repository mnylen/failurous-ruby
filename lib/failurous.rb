require 'net/http'
require 'net/https'

module Failurous
  ROOT = File.dirname(__FILE__)
  
  autoload :Config,           "#{ROOT}/failurous/config"
  autoload :FailNotification, "#{ROOT}/failurous/fail_notification"
  autoload :FailNotifier,     "#{ROOT}/failurous/fail_notifier"
  
  
  # Configures {FailNotifier}. The block will be called
  # with a fresh {Config} instance.
  def self.configure(&block)
    config = Config.new
    block.call(config)
    
    FailNotifier.notifier = FailNotifier.new(config)
  end
end