require_relative '../spec_helper'

describe Photo do
  it "should be equal to an original with the same etag" do
    o = mock Original
    o.should_receive(:respond_to?).with(:etag).twice.and_return true
    o.stub(:etag).and_return 'dc629038ffc674bee6f62eb64ff3a'
    (Photo.new(:etag => 'dc629038ffc674bee6f62eb64ff3a') == o).should be_true
    (Photo.new(:etag => 'non-matching etag') == o).should be_false
  end
  
  it "should only carry a save once in a 10 second period" do
    Couriers::Fusionable.should_receive(:execute).once
    p = Photo.new :etag => 'dc629038ffc674bee6f62eb64ff3a'
    2.times { p.save }
  end
  
  it "should have an accurate preview height" do
    photos = {
      '270' => Photo.new(:dimensions => Dimensions.new(1000, 1000), :key => ''), 
      '54'  => Photo.new(:dimensions => Dimensions.new(200, 1000),  :key => ''), 
      '810' => Photo.new(:dimensions => Dimensions.new(3000, 1000), :key => '')
    }
    photos.each do |height, photo| 
      photo.to_fusion['preview_height'].should eql height.to_s
    end
  end
end
