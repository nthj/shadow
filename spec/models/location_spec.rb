require_relative '../spec_helper'

describe Location do
  it "should create embedded location documents for each placemark when given point" do
    Time.stub!(:now).and_return Time.parse('January 1 2000')
    
    point = mock(Point)
    point.should_receive(:to_a).at_least(:once).and_return [40.756554, -73.986006]
    
    placemark = mock(GeoKit::Geocoders)
    placemark.should_receive(:lat).at_least(:once).and_return 40.756554
    placemark.should_receive(:lng).at_least(:once).and_return -73.986006
    placemark.should_receive(:country_code).at_least(:once).and_return 'US'
    placemark.should_receive(:state).at_least(:once).and_return 'NY'
    placemark.should_receive(:city).at_least(:once).and_return 'New York'
    placemark.should_receive(:street_address).at_least(:once).and_return 'Times Square'
    placemark.should_receive(:zip).at_least(:once).and_return '10036'    
    
    all = mock(Object.new)
    all.should_receive(:all).at_least(:once).and_return [placemark]
    
    GeoKit::Geocoders::GoogleGeocoder.should_receive(:reverse_geocode).with(point.to_a).at_least(:once).and_return(all) 
    
    Location.from_point(point).first.should be_a Location
    Location.from_point(point).first.point.should be_instance_of Point
    Location.from_point(point).first.point.latitude.should eql 40.756554
    Location.from_point(point).first.point.longitude.should eql -73.986006
    Location.from_point(point).first.country.should eql 'US'
    Location.from_point(point).first.state.should eql 'NY'
    Location.from_point(point).first.street.should eql 'Times Square'
    Location.from_point(point).first.locality.should eql 'New York'
    Location.from_point(point).first.postal_code.should be_instance_of PostalCode
    Location.from_point(point).first.postal_code.should eql '10036'
  end
end
