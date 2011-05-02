class Rating
  cattr_accessor :default
  
  self.default = 3
  
  class << self
    def from_mongo value
      Rating.new value
    end

    def to_mongo value
      Rating.new(value).to_i
    end
  end

  def initialize value
    if (1..10) === value.to_i
      @value = value.to_i
    elsif value.to_i > 10
      @value = 10
    else
      @value = 3
    end
  end

  def to_i
    @value.to_i
  end
  
  def to_s
    @value.to_s
  end
  alias inspect to_s
end
