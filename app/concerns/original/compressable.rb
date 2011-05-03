class Original
  module Compressable
    attr_accessor :quality
    
    def compress quality
      self.quality = quality
      self
    end
  end
end
