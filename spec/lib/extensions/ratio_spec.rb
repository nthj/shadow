require_relative '../../spec_helper'

describe Ratio do
  it "should return the ratio when asked for a float" do
    Ratio.new(1.5).to_f.should eql 1.5
  end
  
  it "should query for values greater than or equal to the float minus the precision" do
    Ratio.new(1.5, 0.5).query['$gte'].should eql 1.0
  end
  
  it "should query for values less than or equal to the float plus the precision" do
    Ratio.new(1.5, 0.5).query['$lte'].should eql 2.0
  end
  
  it "should calculate the ratio and return a ratio object" do
    Ratio.calculate(20, 15).should be_a Ratio
    Ratio.calculate(20, 25).to_f.should eql 0.8
  end
  
  it "should handle division by zero" do
    Ratio.calculate(0, 0).to_f.should eql 0.0
  end
end
