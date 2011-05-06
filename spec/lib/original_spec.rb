require_relative '../spec_helper'

describe Original do
  describe Original::Pending do
    it "should add originals to the queue" do
      o = mock(Original)
      o.should_receive(:key).exactly(3).and_return 'above-photography/test.jpg'
      Original::Bucket.should_receive(:all).and_return [o]
      Resque.should_receive(:enqueue).with(Original, o.key).and_return true
      Original::Pending.perform
    end
  end  
end
