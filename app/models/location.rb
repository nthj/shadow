class Location
  include ::MongoMapper::EmbeddedDocument

  key :accuracy,      Integer
  key :point,         Point
  key :country,       String
  key :state,         String
  key :region,        String
  key :locality,      String
  key :street,        String
  key :postal_code,   PostalCode
  key :precision,     String
  
  class << self
    def from_point point
      Array.new.tap do |locations|
        reverse_geocode(point).all.each do |placemark|
          locations << new(
            :point  => Point.new(
              placemark.lat, 
              placemark.lng
            ), 
            :country      => placemark.country_code, 
            :state        => placemark.state, 
            :street       => placemark.street_address, 
            :locality     => placemark.city, 
            :postal_code  => placemark.zip
          )
        end unless point.nil?
      end
    end
    
    def from_ip address
      ::GeoKit::Geocoders::MultiGeocoder.geocode(address).to_a
    end
    
    def reverse_geocode point
      ::GeoKit::Geocoders::GoogleGeocoder.reverse_geocode point.to_a
    end
  end
end
