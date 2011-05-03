class Original
  module Watermarkable
    def watermark
      @filters << lambda { |image|
        image.composite!(
          ::Magick::Image.read(Rails.root.join('config', 'watermark.png')).first, 
          ::Magick::CenterGravity, 
          ::Magick::OverCompositeOp
        )
      }

      self
    end
  end
end
