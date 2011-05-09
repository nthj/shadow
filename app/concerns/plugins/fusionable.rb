module Plugins
  module Fusionable
    def to_fusion
      { 'description'     => description, 
        'geometry'        => point.to_kml,
        'name'            => key,
        'preview'         => Key.new(key).medium,
        'preview_height'  => dimensions.calculate(Processors::Previewer.width.pixels.wide).height,
        'preview_width'   => Processors::Previewer.width,
        'title'           => title }
    end
  end
end
