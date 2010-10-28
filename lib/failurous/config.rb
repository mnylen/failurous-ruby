module Failurous
  # Stores configuration for FailNotifier
  class Config
    # Project's API key in Failurous
    attr_accessor :api_key
    
    # Server name
    attr_accessor :server_name
    
    # Server port (defaults to 80)
    attr_accessor :server_port
    
    # Timeout for sending fails, in seconds (defaults to 2 seconds)
    attr_accessor :send_timeout
    
    # Use SSL? Failurous server must be able to receive fails over HTTPS when this is set to true (defaults to false)
    attr_accessor :use_ssl
    
    # Logger instance for logging errors 
    attr_accessor :logger
    
    
    def initialize
      @server_port  = 80
      @use_ssl      = false
      @send_timeout = 2
    end
  end
end