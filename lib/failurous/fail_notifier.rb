require 'net/http'
require 'net/https'
require 'json'

module Failurous
  
  # FailNotifier is used for notifying Failurous about fails.
  #
  # To send a notification, use the {#notify} method.
  #
  # You can use {.notify} directly as a class level method once the notifier has been
  # configured with {Failurous.configure}
  class FailNotifier

    class << self
      # Notifier configured with {.configure}
      attr_accessor :notifier
      
      # Sends the notification using the configured notifier.
      # @see #notify
      def notify(*args)
        if notifier
          self.notifier.send(:notify_with_caller, args, caller[0])
        else
          raise RuntimeError.new("No notifier configured. Please configure the notifier using Failurous.configure")
        end
      end
    end
    
    # Initializes the notifier with the specified configuration.
    # Optionally takes preconfigured {Net::HTTP} instance for sending notifications.
    #
    # @param config [Failurous::Config] the configuration
    # @param http [Net::HTTP] preconfigured HTTP instance for sending notifications
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
    
    # Sends a notification. The notification can be either:
    # * {Failurous::FailNotification} instance
    # * {Exception} - a new notification is built and sent with the exception details
    # * {String} - a new notification will be built with the given title
    # * {String}, {Exception} - a new notification will be built and sent with the given title and exception details
    #
    # @see FailNotification#initialize
    def notify(*notification)
      notify_with_caller(notification, caller[0])
    end
    
        
    private
    
      def create_notification(args, original_caller)
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
        
        notification
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
        notification = create_notification(args, original_caller)
        @http.post(@path, notification.attributes.to_json)
        
        notification
      rescue
        if @config.logger
          @config.logger.warn("Could not send FailNotification to Failurous: #{$!.class}: #{$!.message}")
        end
      end
  end
end