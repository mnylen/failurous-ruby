require 'net/http'
require 'net/https'
require 'json'

module Failurous
  
  # FailNotifier is used for notifying Failurous about fails.
  #
  # To send a notification, use the {#notify} method.
  class FailNotifier
    class << self
      # Notifier configured with {.configure}
      attr_accessor :notifier
    end
    
    # Configuration for this FailNotifier
    attr_accessor :config
    
    # Initializes the notifier with the specified configuration.
    # Optionally takes preconfigured {Net::HTTP} instance for sending notifications.
    #
    # @param config [Failurous::Config] the configuration
    # @param http [Net::HTTP] preconfigured HTTP instance for sending notifications
    def initialize(config, http = nil)
      @config = config
      @http   = http ? http : create_http_from_config(config)
      @path   = "/api/projects/#{config.api_key}/fails"
    end
    
    # Sends a notification. The notification can be either:
    # * {Failurous::FailNotification} instance
    # * {Exception} - a new notification is built and sent with the exception details
    # * {String} - a new notification will be built with the given title
    # * {String}, {Exception} - a new notification will be built and sent with the given title and exception details
    #
    # You can optionally append the object at the end of argument list to fill the notification
    # details using information available from the object.
    # 
    # == Usage examples:
    #  notifier.notify(FailNotification.new(...))
    # sends the notification passed as an argument
    #
    #  notifier.notify("Something horrible happened!")
    # sends a notification with title _Something_ _horrible_ _happened!_
    #
    #  begin
    #    raise 'hell'
    #  rescue => ex
    #    notifier.notify("ALL HELL HAS BROKEN LOSE", ex)
    #    # or notifier.notify(ex) for the default title
    #  end
    # sends a notification with title _ALL_ _HELL_ _HAS_ _BROKEN_ _LOSE_, which is filled
    # with details from the exception.
    #
    #  notifier.notify("Something weeeeeird is going on", self)
    # sends a notification with title _Something_ _weeeeeird_ _is_ _going_ _on_, with information
    # available from the calling object.
    # @see FailNotification#initialize
    def notify(*notification)
      notify_with_caller(notification, caller[0])
    end
    
        
    private
    
      def create_notification(args, original_caller)
        notification_klass = @config.custom_notification || FailNotification
        
        notification = case identify_args(args)
          when :notification then args[0]
          when :exception then notification_klass.new(nil, args[0], args[1])
          when :exception_with_message then notification_klass.new(args[0], args[1], args[2])
          when :message then notification_klass.new(args[0], nil, args[1])
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
      rescue Timeout::Error => ex
        log_error(ex) # Timeout:Error doesn't derive from StandardError...
      rescue => ex
        log_error(ex)
      end
      
      def log_error(ex)
        if @config.logger
          @config.logger.warn("Could not send FailNotification to Failurous: #{ex.class}: #{ex.message}")
        end
      end
      
      def create_http_from_config(config)
        http = ::Net::HTTP.new(config.server_name, config.server_port)
        http.use_ssl = config.use_ssl
        http.open_timeout = config.send_timeout
        http.read_timeout = config.send_timeout
        
        if config.https_ca_file
          http.ca_file = config.https_ca_file
        end
        
        if config.https_verify_mode
          http.verify_mode = config.https_verify_mode
        end
        
        http
      end
  end
end