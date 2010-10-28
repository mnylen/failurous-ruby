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
        notification = case identify_args(args)
          when :notification then args[0]
          when :exception then FailNotification.new(nil, args[0])
          when :exception_with_message then FailNotification.new(args[0], args[1])
          when :message then FailNotification.new(args[0])
        end
        
        if identify_args(args) == :message
          notification.location = original_caller unless notification.location_set?
          notification.use_location_in_checksum = true unless notification.location_set?
        end
        
        notification.attributes.to_json
      end
      
      def identify_args(args)
        if args[0].kind_of?(FailNotification)
          return :notification
        elsif args[0].kind_of?(Exception)
          return :exception
        elsif args[0].kind_of?(String) and args[1].kind_of?(Exception)
          return :exception_with_message
        else
          return :message
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