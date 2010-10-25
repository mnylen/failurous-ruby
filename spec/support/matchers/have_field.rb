RSpec::Matchers.define :have_field do |section_name, field_name|
  chain :with_value do |value|
    @value = value
  end
  
  match do |actual|
    section = find_section(actual, section_name)
    field   = find_field(section, field_name) if section
    
    result = !(field.nil?)
    result = (field[1] == @value) if (field and @value)
    
    result
  end

  failure_message_for_should do |actual|
    message = "expected that #{actual} has field #{field_name} in #{section_name}"
    message += " with value #{@value}" if @value
    
    message
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual} does not have field #{field_name} in #{section_name}"
  end
  
  def find_section(notification, section_name)
    notification.attributes[:data].detect { |section| section[0] == section_name }
  end
  
  def find_field(section, field_name)
    section[1].detect { |field| field[0] == field_name }
  end
end
