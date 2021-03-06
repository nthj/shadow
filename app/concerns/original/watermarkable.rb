class Original
  module Watermarkable
    def watermark
      @filters << lambda { |key, image|
        notify "Watermarking", key
        image.composite!(
          ::Magick::Image.read(Rails.root.join('config', 'watermark.png')).first, 
          ::Magick::CenterGravity, 
          ::Magick::OverCompositeOp
        ) unless Rails.env.development?
      }

      self
    end
  end
end
