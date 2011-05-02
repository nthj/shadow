GeoKit::Geocoders::google             = ENV['GOOGLE_MAPS_API_KEY'] or raise RuntimeError, "Please set GOOGLE_MAPS_API_KEY"
GeoKit::Geocoders::provider_order     = :google
