require_relative '../../spec_helper'

describe Orientation do
  context "when right side up" do
    it "should be a landscape" do
      Orientation.new(1).landscape?.should be_true
    end
  
    it "should not be a portrait" do
      Orientation.new(1).portrait?.should be_false
    end
  end
  
  context "when up side down" do
    it "should be a landscape" do
      Orientation.new(3).landscape?.should be_true
    end
  
    it "should not be a portrait" do
      Orientation.new(3).portrait?.should be_false
    end
  end
  
  context "when on left side" do
    it "should not be a landscape" do
      Orientation.new(6).landscape?.should be_false
    end
  
    it "should be a portrait" do
      Orientation.new(6).portrait?.should be_true
    end
  end
  
  context "when on right side" do
    it "should not be a landscape" do
      Orientation.new(8).landscape?.should be_false
    end
  
    it "should be a portrait" do
      Orientation.new(8).portrait?.should be_true
    end
  end
  
  context "when horizontally flipped" do
    context "and right side up" do
      it "should be a landscape" do
        Orientation.new(2).landscape?.should be_true
      end

      it "should not be a portrait" do
        Orientation.new(2).portrait?.should be_false
      end
    end

    context "and up side down" do
      it "should be a landscape" do
        Orientation.new(4).landscape?.should be_true
      end

      it "should not be a portrait" do
        Orientation.new(4).portrait?.should be_false
      end
    end

    context "and on left side" do
      it "should not be a landscape" do
        Orientation.new(5).landscape?.should be_false
      end

      it "should be a portrait" do
        Orientation.new(5).portrait?.should be_true
      end
    end

    context "and on right side" do
      it "should not be a landscape" do
        Orientation.new(7).landscape?.should be_false
      end

      it "should be a portrait" do
        Orientation.new(7).portrait?.should be_true
      end
    end 
  end
  
  it "should raise an error for unknown values" do
    lambda { Orientation.new(82) }.should raise_error(UnknownOrientationError)
  end
  
  it "should default to 1 if the value is nil" do
    Orientation.new(nil).to_i.should eql 1
  end
  
  it "should force to integer making from the exif data" do
    Orientation.from_exif('5').to_i.should eql 5
  end
  
  it "should accept an orientation object from the database" do
    Orientation.from_mongo(Orientation.new(3)).should_not raise_error(UnknownOrientationError)
  end
  
  context "when saving to mongo" do
    it "should save nil values as 1" do
      Orientation.to_mongo(Orientation.new(nil)).should eql 1
    end
  end
end
