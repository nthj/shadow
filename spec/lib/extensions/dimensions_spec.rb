require_relative '../../spec_helper'

describe Dimensions do
  context "when converting mongo values" do
    it "should become a hash with named integers and a float" do
      Dimensions.to_mongo(Dimensions.new(5, 10)).should eql(
        {
          'height' => 5, 
          'width'  => 10, 
          'ratio'  => 0.5
        }
      )
    end
    
    it "should accept a hash" do
      Dimensions.from_mongo(
        {
          'height' => 5, 
          'width'  => 10
        }
      ).to_a.should eql [5, 10]
    end
  end
  
  it "should calculate new dimensions when given a pixel" do
    Dimensions.new(100, 200).calculate(50.pixels.wide).to_a.should eql [25, 50]
  end
  
  it "should turn into an image_tag usable string" do
    Dimensions.new(100, 200).to_s.should eql '200x100'
  end
end
