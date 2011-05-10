require_relative '../spec_helper'

describe Photo do
  it "should be equal to an original with the same etag" do
    o = mock Original
    o.should_receive(:respond_to?).with(:etag).twice.and_return true
    o.stub(:etag).and_return 'dc629038ffc674bee6f62eb64ff3a'
    (Photo.new(:etag => 'dc629038ffc674bee6f62eb64ff3a') == o).should be_true
    (Photo.new(:etag => 'non-matching etag') == o).should be_false
  end
  
  it "should only carry a save one time in 3 seconds" do
    Resque.should_receive(:enqueue).once
    p = Photo.new :etag => 'dc629038ffc674bee6f62eb64ff3a'
    2.times { p.save }
  end
end
