# frozen_string_literal: true

# Create the default organization
org = Organization.find_or_create_by!(slug: "pimu-uc") do |o|
  o.name = "PIMU UC"
  o.settings = {
    "max_messages_per_hour" => 30,
    "max_tokens_per_day" => 100_000
  }
end

puts "Organization '#{org.name}' (#{org.slug}) ready."
