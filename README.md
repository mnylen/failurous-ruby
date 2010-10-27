# failurous-ruby

failurous-ruby is a Ruby client library used for sending fail notifications to
Failurous (see http://github.com/mnylen/failurous).

## Installation

TBD

## Configuration

To start using the client, it must be configured with the address and port of the Failurous
server and the API key for the project it's used in.

This can be achieved by calling `Failurous.configure`:

    Failurous.configure do |config|
      config.server_name = "failurous.mycompany.com"
      config.server_port = 443
      config.api_key     = "API KEY for your project"
    end

You can also configure the following obligatory options:

* *use_ssl* - set to _true_ to encrypt notifications using SSL (defaults to _false_)
* *send_timeout* - when Failurous server is slow to respond, this determines how long, in seconds, the notifier should wait before timing out (defaults to _2_)
* *logger* - in case the notifications could not be sent, the logger is used to log the reason (by default, no logger is used)

## Usage

Fail notifications are sent using `Failurous::FailNotifier.send(notification)` or by creating
a notification using `Failurous::FailNotification.new` and calling `send` on it.

Basic usage example:

    def somemethod
      some
      failing
      code
    rescue => ex
      Failurous::FailNotification.new("#{ex.class} in somemethod", ex).
        add_field(:section, :field_name, "field value", { :use_in_checksum => false, :humanize_field_name => true }).
        send
    end
    
For full syntax, see the documentation for `FailNotification`

## Support & Bug Reports

\#failurous @ FreeNode

[Failurous Lighthouse](http://failurous.lighthouseapp.com/dashboard)

## License

Copyright (c) 2010 Mikko Nylén, Tero Parviainen & Antti Forsell

See LICENSE