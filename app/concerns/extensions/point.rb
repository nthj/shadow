class Point
  class << self     
    def from_a value
      new value.first, value.last
    end
    
    def from_map value
      point = value.split(', ')
      new point.first[1, point.first.length], point.last[0, point.last.length - 1]
    end
    
    def from_mongo value
      if value.nil? 
        new nil, nil
      elsif value.is_a?(self)
        value
      else
        new value['latitude'] || value[:latitude], value['longitude'] || value[:longitude]
      end
    end
    
    def to_mongo value
      value.to_hash unless value.nil?
    end
  end
  
  attr_reader :latitude, :longitude
  
  def initialize latitude, longitude
    @latitude  = latitude.to_f  if Latitude.valid? latitude
    @longitude = longitude.to_f if Longitude.valid? longitude
  end
  
  def blank?
    ( latitude.nil? || latitude.zero? ) && ( longitude.nil? || longitude.zero? )
  end
  
  def inspect
    to_hash.inspect
  end
  
  def to_a
    [latitude, longitude]
  end
  
  def to_hash
    {
      :latitude   => latitude,
      :longitude  => longitude
    }
  end
  
  def to_kml
    "<Point>
      <coordinates>#{latitude},#{longitude},0.0</coordinates>
    </Point>"    
  end
  
  def to_s
    "(#{latitude}, #{longitude})"
  end
end

class Coordinate
  REFERENCE_MATCH = //
  VALIDITY_MATCH  = //
  
  class << self
    def valid? float
      float.to_s =~ self::VALIDITY_MATCH
    end
  end
  
  def initialize coordinate, reference = nil
    @coordinate = coordinate
    @reference  = reference
  end

  def to_f
    @reference =~ self::class::REFERENCE_MATCH ? @coordinate.to_f * -1 : @coordinate.to_f
  end

  def to_s
    to_f.to_s
  end
end

class Latitude < Coordinate
  REFERENCE_MATCH = /s/i
  VALIDITY_MATCH  = /^\s*[-+]?(90\.[0]+|[0-8]?[0-9]{1}\.\d+)\s*$/
end

class Longitude < Coordinate
  REFERENCE_MATCH = /w/i
  VALIDITY_MATCH  = /^\s*[-+]?(180\.[0]+|1[1-7]{1}[0-9]{1}\.\d+|[0-9]{1,2}\.\d+)\s*$/
end
