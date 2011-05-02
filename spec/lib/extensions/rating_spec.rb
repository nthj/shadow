require_relative '../../spec_helper'

describe Rating do
  it "should default to #{Rating::default}" do
    Rating.new(nil).to_i.should eql Rating::default
  end
  
  it "should be no larger than 10" do
    Rating.new(11).to_i.should eql 10
  end
  
  it "should accept all values between 1 and 10" do
    (1..10).each do |rating|
      Rating.new(rating).to_i.should eql rating
    end
  end
  
  it "should be stringable" do
    Rating.new(5).to_s.should eql '5'
  end
  
  it "should be inspectable" do
    Rating.new(5).inspect.should eql '5'
  end
  
  context "when saving to and from the databse" do
    it "should be a Rating object" do
      Rating.from_mongo(5).should be_a Rating
    end
    
    it "should handle being given a rating object" do
      Rating.from_mongo(Rating.new(5)).should be_a Rating
    end
    
    it "should be stored as an integer" do
      Rating.to_mongo(Rating.new(5)).should be_a Integer
      Rating.to_mongo(Rating.new(5)).should eql 5
    end
    
    it "should store nil values as the default rating" do
      Rating.to_mongo(nil).should eql Rating::default
    end
  end
end
