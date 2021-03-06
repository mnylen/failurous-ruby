RSpec::Matchers.define :have_field do |section_name, field_name|
  chain :with_value do |value|
    @value = value
  end
  
  chain :with_options do |options|
    @options = options
  end
  
  chain :below do |below|
    @below = below
  end
  
  chain :above do |above|
    @above = above
  end
  
  chain :as_last_field do
    @last_field = true
  end
  
  match do |actual|
    section = find_section(actual, section_name)
    field   = find_field(section, field_name, @below, @above, @last_field) if section
    
    result = !(field.nil?)
    result = (field[1] == @value) if (field and @value)
    
    if @options and field
      @options.each_pair do |key, value|
        if field[2][key] != value
          result = false
          break
        end
      end
    end
    
    result
  end

  failure_message_for_should do |actual|
    message = "expected that #{actual} has field #{field_name} in #{section_name}"
    message += " with value #{@value}" if @value
    message += " and with options #{@options.inspect}" if @options
    message += " below field #{@below}" if @below
    message += " above field #{@above}" if @above
    message += " as last field" if @last_field

    message
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual} does not have field #{field_name} in #{section_name}"
  end
  
  def find_section(notification, section_name)
    notification.attributes[:data].detect { |section| section[0] == section_name }
  end
  
  def find_field(section, field_name, below, above, last_field)
    if last_field
      if section[1].last[0] == field_name
        return section[1].last
      else
        return nil
      end
    end
    
    previous_field = nil
    
    section[1].size.times do |i|
      field = section[1][i]
      
      if field[0] == field_name
        if below
          return (previous_field and previous_field[0] == below) ? field : nil
        elsif above
          return (section[1][i+1][0] == above) ? field : nil
        else
          return field
        end
      end
      
      previous_field = field
    end
    
    nil
  end
end
