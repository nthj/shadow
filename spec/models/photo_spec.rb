require_relative '../spec_helper'

describe Photo do
  it "should be equal to an original with the same etag" do
    o = mock Original
    o.should_receive(:responds_to?).with(:etag).twice.and_return true
    o.stub(:etag).and_return 'dc629038ffc674bee6f62eb64ff3a'
    (Photo.new(:etag => 'dc629038ffc674bee6f62eb64ff3a') == o).should be_true
    (Photo.new(:etag => 'non-matching etag') == o).should be_false
  end
end