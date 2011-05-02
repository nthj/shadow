class InvalidDegreesError < ArgumentError; end

class Degrees < Struct.new(:degrees, :minutes, :seconds)
  class << self      
    def from_a array
      raise InvalidDegreesError, array.inspect unless array.kind_of?(Array) && array.size == 3
      new(array[0].to_f, array[1].to_f, array[2].to_f)
    end
    
    def from_string string
      raise InvalidDegreesError, string.inspect unless string.respond_to?(:split)
      from_a string.split(', ').map { |d| d.split('/').first.to_i / d.split('/').last.to_i }
    end
  end
  
  def to_f
    degrees.to_f + minutes.to_f / 60 + seconds.to_f / 3600
  end
end
