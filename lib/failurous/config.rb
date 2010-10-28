module Failurous
  class Config
    attr_accessor :api_key
    attr_accessor :server_name
    attr_accessor :server_port
    attr_accessor :send_timeout
    attr_accessor :use_ssl
    attr_accessor :logger
    
    def initialize
      @server_port  = 80
      @use_ssl      = false
      @send_timeout = 2
    end
  end
end