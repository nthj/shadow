module Plugins
  module Fusionable
    def to_fusion
      { 'description' => description, 
        'geometry'    => point.to_kml,
        'name'        => key,
        'preview'     => key.medium,
        'title'       => title }
    end
  end
end
