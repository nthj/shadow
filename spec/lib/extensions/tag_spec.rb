require_relative '../../spec_helper'

describe Tag do
  context "before saving to the database" do
    it "should downcase and parameterize the tag" do
      Tag.to_mongo('Twelve Apostles National Park').should eql 'twelve-apostles-national-park'
    end
  
    it "should strip the tag" do
      Tag.to_mongo(' Blue Water').should eql 'blue-water'
    end
  end
  
  context "when given a string of keywords" do
    it "should create an array of tags" do
      Tag.from_keywords('Twelve Apostles National Park, Blue Water; Kite Surfing').should eql ['Twelve Apostles National Park', 'Blue Water', 'Kite Surfing']
    end
    
    it "should return an array even if the image didn't provide a string" do
      Tag.from_keywords(nil).should eql []
    end
    
    it "should strip the number off the end of a color" do
      Tag.from_keywords('Blue 3; Green 4; White 2').should eql ['Blue', 'Green', 'White']
    end
    
    it "should uniquify the keywords" do
      Tag.from_keywords('Blue; Blue; Green; Green').should eql ['Blue', 'Green']
    end
  end
end
