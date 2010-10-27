module Failurous
  class Config
    class << self
      attr_accessor :server_name
      attr_accessor :server_port
      attr_accessor :send_timeout
      attr_accessor :use_ssl
      attr_accessor :logger
    end
  end
end