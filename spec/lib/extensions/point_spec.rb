require_relative '../../spec_helper'

describe Point do
  it "should be creatable from an array" do
    Point.from_a([0.2, 0.191]).should be_a Point
  end
  
  it "should be creatable from a hash" do 
    Point.from_mongo({ :latitude => 82.82, :longitude => 82.8328}).should be_a Point
  end
  
  it "should be creatable from a hash with stringed keys" do 
    Point.from_mongo({ 'latitude' => 82.82, 'longitude' => 82.8328}).to_a.should eql [82.82, 82.8328]
  end
  
  it "should support negative coordinates" do
    Point.new(-0.2, -0.191).to_a.should eql [-0.2, -0.191]
  end
  
  it "should ignore invalid coordinates" do
    Point.new(90.82837, 180.028182).to_a.should eql [nil, nil]
  end
  
  it "should enter the database as a hash" do
    Point.to_mongo(Point.new(-0.2, -0.191)).should eql Point.new(-0.2, -0.191).to_hash
  end
  
  it "should be hashable" do
    Point.new(-0.2, -0.191).to_hash.should eql({ :latitude => -0.2, :longitude => -0.191 })
  end
  
  it "should accept nil values from the database" do
    Point.from_mongo(nil).to_hash.should eql({ :latitude => nil, :longitude => nil })
  end
  
  it "should return itself when given a coordinates object from the database" do
    Point.from_mongo(Point.new(1, 1)).should be_a Point
  end
  
  it "should be inspectable" do
    Point.new(-0.2, -0.191).inspect.should eql '{:latitude=>-0.2, :longitude=>-0.191}'
  end
end

describe Coordinate do
  it "should be stringable" do
    Coordinate.new(10.0238).to_s.should eql '10.0238'
  end
end

describe Latitude do
  it "should return a negative coordinate if the reference matches" do
    Latitude.new(
      Degrees.new(20, 20, 20), 
      'S'
    ).to_f.should be < 0
  end
  
  it "should return a positive coordinate if the reference is different" do
    Latitude.new(
      Degrees.new(20, 20, 20), 
      'N'
    ).to_f.should be > 0
  end
end

describe Longitude do
  it "should return a negative coordinate if the reference matches" do
    Longitude.new(
      Degrees.new(20, 20, 20), 
      'W'
    ).to_f.should be < 0
  end
  
  it "should return a positive coordinate if the reference is different" do
    Longitude.new(
      Degrees.new(20, 20, 20), 
      'E'
    ).to_f.should be > 0
  end
end
