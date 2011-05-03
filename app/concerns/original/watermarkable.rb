class Original
  module Watermarkable
    def watermark
      @filters << lambda { |image|
        # watermark image
      }
      
      self
    end
  end
end
