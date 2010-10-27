require 'net/http'
require 'net/https'
require 'json'

module Failurous
  class FailNotifier
    class << self
      attr_accessor :http
      
      def send(notification)
        data = notification.attributes.to_json
        self.http.post("/api/projects/#{Failurous::Config.api_key}/fails", data)
      rescue
        if Failurous::Config.logger
          Failurous::Config.logger.warn("Could not send FailNotification to Failurous: #{$!.class}: #{$!.message}")
        end
      end
    end
  end
end