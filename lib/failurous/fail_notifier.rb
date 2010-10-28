require 'net/http'
require 'net/https'
require 'json'

module Failurous
  class FailNotifier

    class << self
      attr_accessor :notifier

      def notify(*args)
        if notifier
          self.notifier.send(:notify_with_caller, args, caller[0])
        else
          raise RuntimeError.new("No notifier configured. Please configure the notifier using Failurous.configure")
        end
      end
    end
  
  
    def initialize(config, http = nil)
      @config = config
      
      unless http
        @http = ::Net::HTTP.new(config.server_name, config.server_port)
        @http.use_ssl = config.use_ssl
        @http.open_timeout = config.send_timeout
      else
        @http = http
      end
      
      @path = "/api/projects/#{config.api_key}/fails"
    end
    
    def notify(*args)
      notify_with_caller(args, caller[0])
    end
    
        
    private
    
      def convert_args_to_json(args, original_caller)
        notification_exception_or_title = args.shift
        exception = args.shift
        
        if notification_exception_or_title.kind_of?(FailNotification)
          notification_exception_or_title.attributes.to_json
        else
          notification = nil
          if notification_exception_or_title.kind_of?(Exception)
            notification = Failurous::FailNotification.new(nil, notification_exception_or_title)
          else
            notification = Failurous::FailNotification.new(notification_exception_or_title, exception)
          end
          
          if exception.nil?
            notification.location = original_caller
            notification.use_location_in_checksum = true
          end
          
          notification.attributes.to_json
        end
      end
      
      
      def notify_with_caller(args, original_caller)
        data = convert_args_to_json(args, original_caller)
        @http.post(@path, data)
      rescue
        if @config.logger
          @config.logger.warn("Could not send FailNotification to Failurous: #{$!.class}: #{$!.message}")
        end
      end
  end
end