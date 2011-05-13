module Plugins
  module Fusionable
    def to_fusion
      { 'description'     => description, 
        'geometry'        => point.to_kml,
        'name'            => key,
        'preview'         => Key.new(key).medium,
        'preview_height'  => preview_height,
        'preview_width'   => preview_width,
        'title'           => title }.filter &:to_s
    end
    
    protected
      def preview_height
        if orientation.landscape?
          dimensions.calculate(Processors::Previewer.width.pixels.wide).height
        else
          Processors::Previewer.height.pixels.high          
        end
      end
      
      def preview_width
        if orientation.landscape?
          Processors::Previewer.width
        else
          dimensions.calculate(Processors::Previewer.height.pixels.high).height
        end
      end
  end
end
