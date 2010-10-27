module Failurous
  class FailNotification
    attr_accessor :attributes
    
    # Creates a new FailNotification using the specified title. The notification
    # will be filled with details from the exception and object, if they are given.
    #
    # Location will default to the caller and is used when combining fails.
    #
    # @param title [String] custom title for the notification, if any -- when given, used when combining fails
    # @param exception [Exception] exception that occured, if any
    # @param object [Object] object that caused the fail notification to be built, if applicable
    #
    # @see FailNotification#fill_from_exception
    # @see FailNotification#fill_from_object
    def initialize(title = nil, exception = nil, object = nil)
      @attributes = {
        :title => title,
        :location => caller[0],
        :use_title_in_checksum => false,
        :use_location_in_checksum => false,
        :data => []
      }
      
      @location_set = false
      self.use_title_in_checksum = true if title
      fill_from_exception(exception) if exception
      fill_from_object(object) if object
    end

    # Fills notification details from the given exception. Please note that
    # if the title and/or location has been specified previously, those
    # are not overriden here.
    #
    # * *Title* will be set to _type:_ _message_. Not used when combining fails. 
    # * *Location* will be set as the topmost frame in backtrace. Used when combining fails.
    #
    # Two sections will be added:
    #
    # Summary
    # * Type (*:type*) of the exception -- used when combining fails 
    # * Exception *message* (*:message*) -- not used when combining fails
    # * Topmost line in backtrace (*:topmost_line_in_backtrace*) -- used when combining fails 
    #
    # Details
    # * Full backtrace (*:full_backtrace*) -- not used when combining fails
    #
    # @param exception [Exception] the exception raised 
    # @return [FailNotification] self
    def fill_from_exception(exception)
      self.title = "#{exception.class}: #{exception.message}" unless self.title
      unless location_set?
        self.location = exception.backtrace[0]
        self.use_location_in_checksum = true
      end
      
      self.add_field(:summary, :type, exception.class.to_s, :use_in_checksum => true).
        add_field(:summary, :message, exception.message, :use_in_checksum => false).
        add_field(:summary, :topmost_line_in_backtrace, exception.backtrace[0], :use_in_checksum => true).
        add_field(:details, :full_backtrace, exception.backtrace.join('\n'), :use_in_checksum => false)
        
      self
    end


    # Fills notification details from the given object. The base implementation
    # does nothing.
    #
    # @param object [Object] the object to fill from
    # @return [FailNotification] self
    def fill_from_object(object)
      self
    end

    
    # Adds a field to the notification. The field will be added to the named section _section_name_ with
    # name _field_name_ and value of _field_value_.
    #
    # If the section does not exists, it will be created. Otherwise the field is added to the section.
    # If the field already exists inside the section, it will be overriden.
    #
    # _field_options_ can contain any options for fields supported by Failurous. At least the following
    # are supported:
    # * _:use_in_checksum_ - *true* if the field should be used when combining fails, defaults to *false*
    # * _:humanize_field_name_ - *true* if the field name should be humanized, defaults to *true*
    # For a full list of supported field options, please see the API documentation for Failurous.
    #
    # Placement of the field inside section can be controller with _placement_. If no placement options
    # are given, the field will be appended to the end of the section. Supported options are:
    # * _:below_ - the field should be placed below the specified field (e.g. *:below* => *:type*)
    # * _:above_ - the field should be placed above the specified field (e.g. *:after* => *:message*)
    # Currently combining _:below_ and _:above_ is not supported.
    #
    # @param section_name [Symbol] name of the section
    # @param field_name [Symbol] name of the section
    # @param field_value [Object] value for the field, will be converted to string using {Object.inspect} if it isn't already a string
    # @param field_options [Hash] options for field
    # @param placement [Hash] placement options
    #
    # @return [FailNotification] self
    def add_field(section_name, field_name, field_value, field_options = {}, placement = {})
      if placement[:above] and placement[:below]
        raise ArgumentError.new("Ambiguous placement options: only one of :below or :above can be specified")
      end
      
      field   = [ field_name, field_value, field_options ]
      section = find_section(section_name)
      
      unless section
        section = [section_name, [ ] ]
        @attributes[:data] << section
      end
      
      insert_or_replace_field(section, field, placement)
      
      self
    end

    # Gets the location, or the caller of {#initialize} when the location has not been
    # set by using {#location=}
    #
    # @return location
    def location
      @attributes[:location]
    end

    # Sets the location to the specified location. Will override any previous
    # value.
    #
    # @param location [String] the location
    # @see #use_location_in_checksum
    # @see #use_location_in_checksum=
    def location=(location)
      @location_set = true
      @attributes[:location] = location
    end
    
    # @return [Boolean] *true* if the location was set using {#location=}, otherwise *false*
    def location_set?
      @location_set
    end

    # Gets whether _location_ should be used when combining fails. Defaults to *false*
    #
    # @return [Boolean] *true* if location should be used when combining fails; *false* otherwise
    def use_location_in_checksum
      @attributes[:use_location_in_checksum]
    end

    # Sets whether _location_ should be used when combining fails. 
    #
    # @param value [Boolean] *true* if location should be used when combining fails; *false* otherwise
    def use_location_in_checksum=(value)
      @attributes[:use_location_in_checksum] = value
    end


    # Gets the title for notification
    #
    # @return title 
    def title 
      @attributes[:title]
    end

    # Sets the title to specified title. Will override any previous value.
    #
    # @param title [String] the title 
    # @see #use_title_in_checksum
    # @see #use_title_in_checksum=
    def title=(title)
      @attributes[:title] = title
    end

    # Gets whether _title_ should be used when combining fails. Defaults to *false*
    #
    # @return [Boolean] *true* if title should be used when combining fails; *false* otherwise
    def use_title_in_checksum
      @attributes[:use_title_in_checksum]
    end

    # Sets whether _title_ should be used when combining fails. 
    #
    # @param value [Boolean] *true* if title should be used when combining fails; *false* otherwise
    def use_title_in_checksum=(value)
      @attributes[:use_title_in_checksum] = value
    end
    
    # Sends the notification using {FailNotifier}
    def send
      FailNotifier.send(self)
    end
    
    
    private
    
      def find_section(section_name)
        @attributes[:data].detect { |section| section[0] == section_name }
      end

      def insert_or_replace_field(section, field, placement)
        if placement[:below] or placement[:above]
          remove_field(section, field[0])
          insert_field_below(placement[:below], section, field) if placement[:below]
          insert_field_above(placement[:above], section, field) if placement[:above]
        else
          unless replace_field(section, field)
            section[1] << field
          end
        end
      end
      
      def insert_field_below(field_name, section, new_field)
        i = field_index(section, field_name)
        
        if i
          section[1].insert(i+1, new_field)
        else
          section[1] << new_field
        end
      end
      
      def insert_field_above(field_name, section, new_field)
        i = field_index(section, field_name)
        
        if i
          section[1].insert(i, new_field)
        else
          section[1] << new_field
        end
      end
      
      def remove_field(section, field_name)
        i = field_index(section, field_name)
        section[1].delete_at(i) if i
      end

      def replace_field(section, field)
        i = field_index(section, field[0])
        
        if i
          section[1][i] = field
          true
        else
          false
        end
      end
      
      def field_index(section, field_name)
        section[1].size.times do |i|
          if section[1][i][0] == field_name
            return i
          end
        end
        
        nil
      end
  end
end
