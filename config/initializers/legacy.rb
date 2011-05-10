begin
  Couriers::Legacy.key          = ENV['LEGACY_API_KEY'].split('@').first
  Couriers::Legacy.destination  = ENV['LEGACY_API_KEY'].split('@').last
rescue NoMethodError
  puts "[ERROR] Please add a LEGACY_API_KEY in the form `key@destination`"
end
