class UnknownOrientationError < ArgumentError
  def initialize value = nil
    msg  = "Unknown Orientation: should be a number 1 through 8 or nil"
    msg += " (was #{value})" unless value.nil?
    super msg
  end
end 

class Orientation
  class << self
    def from_exif value
      Orientation.new(value.to_i || 1)
    end

    def from_mongo value
      Orientation.new(value || 1)
    end

    def to_mongo value
      value.to_i
    end
  end

  def initialize value
    case value
    when nil                    then @value = 1
    when ValidOrientationValue  then @value = value.to_i
    else raise UnknownOrientationError, "#{value} with #{value.to_i}"
    end
  end

  def landscape?
    (1..4) === @value
  end

  def portrait?
    (5..8) === @value
  end

  def to_i
    @value
  end
  alias inspect to_i
end

class ValidOrientationValue
  def self.=== value
    (1..8) === value.to_i
  end
end
