require 'net/http'
require 'net/https'
require 'json'

module Failurous
  class FailNotifier
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
    
    def notify(notification)
      data = notification.attributes.to_json
      @http.post(@path, data)
    rescue
      if @config.logger
        @config.logger.warn("Could not send FailNotification to Failurous: #{$!.class}: #{$!.message}")
      end
    end
    
    
    class << self
      attr_accessor :notifier
      
      def notify(*args)
        if notifier
          self.notifier.notify(*args)
        else
          raise RuntimeError.new("No notifier configured. Please configure the notifier using Failurous.configure")
        end
      end
    end
  end
end