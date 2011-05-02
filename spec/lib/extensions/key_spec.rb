require_relative '../../spec_helper'

describe Key do
  it "should insert the type into the key after the basename and before the extension" do
    Key.new('photo.jpg').small.should eql 'photo_small.jpg'
  end
  
  it "should handle various extensions" do
    ['jpg', 'png', 'jpeg'].each do |extension|
      Key.new("photo.#{extension}").small.should eql "photo_small.#{extension}"
    end
  end
  
  it "should return a frozen key" do
    Key.new("photo.jpg").small.frozen?.should be_true
    Key.new("photo.jpg").small.should be_a Key
  end
  
  it "should have an existence flag" do
    Asset.stub!(:exists?).and_return false, true
    Key.new("photo.jpg").small.exists?.should be_false
    Key.new("photo.jpg").exists?.should be_true  
  end
  
  it "should be initializable from mongo" do
    Key.from_mongo('photo.jpg').should be_a Key
    Key.from_mongo('photo.jpg').should eql 'photo.jpg'
  end
  
  it "should return the default key for missing types" do
    Key.new("photo.jpg").large.frozen?.should be_true
    Key.new("photo.jpg").large.should be_a Key
    Key.new("photo.jpg").large.should eql 'photo.jpg'
  end
  
  it "should return the default key for the keyword default" do
    Key.new("photo.jpg").default.frozen?.should be_true
    Key.new("photo.jpg").default.should be_a Key
    Key.new("photo.jpg").default.should eql 'photo.jpg'
  end
  
  it "should return a nice-looking title" do
    Key.new("bob/one-photo.jpg").titleize.should eql 'One Photo'
  end
  
  it "should handle upper-case extensions" do
    Key.new("bob/one-photo.JPG").titleize.should eql 'One Photo'
  end
  
  it "should handle extensions with an e" do
    Key.new('bob/one-photo.jpeg').titleize.should eql 'One Photo'
  end
  
  context "when finding a key's photographer" do
    it "should return a string" do
      Key.new('above-photography/cloudy-day.jpg').photographer.should eql 'above-photography'
    end
    
    it "should ignore any requests when the key has no slash" do
      Key.new('cloudy-day.jpg').photographer.should eql nil
    end
  end
  
  it "should let us prepend a photographer's key" do
    Key.new('cloudy-day.jpg').own('above-photography').should eql 'above-photography/cloudy-day.jpg'
  end
end
