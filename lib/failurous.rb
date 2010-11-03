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
  
  
  # Sends the notification using the configured notifier.
  # @see FailNotifier#notify
  # @see Failurous.configure
  def self.notify(*args)
    if FailNotifier.notifier
      FailNotifier.notifier.send(:notify_with_caller, args, caller[0])
    else
      raise RuntimeError.new("No notifier configured. Please configure the notifier using Failurous.configure")
    end
  end
end