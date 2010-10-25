RSpec::Matchers.define :have_section do |section_name|
  match do |actual|
    found = false

    actual.attributes[:data].each do |section|
      if section[0] == section_name
        found = true
        break
      end
    end

    found == true
  end

  failure_message_for_should do |actual|
    "expected that #{actual} has section #{section_name}"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual} does not have section #{section_name}"
  end
end
