module Failurous
  ROOT = File.dirname(__FILE__)
  
  autoload :Config,           "#{ROOT}/failurous/config"
  autoload :FailNotification, "#{ROOT}/failurous/fail_notification"
end