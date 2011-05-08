begin
  Couriers::Fusionable.username = ENV['GOOGLE_FUSION_API_KEY'].split(':').first
  Couriers::Fusionable.password = ENV['GOOGLE_FUSION_API_KEY'].split(':')[1]
  Couriers::Fusionable.table_id = ENV['GOOGLE_FUSION_API_KEY'].split(':').last
rescue NoMethodError
  puts "[ERROR] Please add a GOOGLE_FUSION_API_KEY in the form `email:password:tableID`"
end
