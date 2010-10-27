require 'net/http'
require 'net/https'

module Failurous
  ROOT = File.dirname(__FILE__)
  
  autoload :Config,           "#{ROOT}/failurous/config"
  autoload :FailNotification, "#{ROOT}/failurous/fail_notification"
  autoload :FailNotifier,     "#{ROOT}/failurous/fail_notifier"
  
  
  def self.configure(&block)
    block.call(Config)
    
    # Initialize the HTTP object for sending fails
    FailNotifier.http = ::Net::HTTP.new(Config.server_name, Config.server_port)
    FailNotifier.http.use_ssl = Config.use_ssl || false
    FailNotifier.http.open_timeout = Config.send_timeout || 2
  end
end