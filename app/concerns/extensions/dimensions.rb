class Dimensions    
  class << self
    def from_mongo value
      if value.nil?
        Dimensions.new 0, 0
      else
        Dimensions.new value['height'], value['width']
      end
    end
    
    def to_mongo value
      value.to_hash unless value.nil?
    end
  end
  
  attr_reader :height, :ratio, :width

  def initialize height, width
    @height = height
    @width  = width
    @ratio  = Ratio.calculate height, width
  end
  
  def [] key
    case key
    when 'height' then height
    when 'width'  then width
    else raise ArgumentError
    end
  end

  def calculate unit
    height, width = unit.calculate(self)
    self.class.new height, width
  end
  
  def inspect
    to_hash.inspect
  end
  
  def to_a
    [height, width]
  end

  def to_hash
    {
      'height' => @height.to_i, 
      'width'  => @width.to_i, 
      'ratio'  => @ratio.to_f
    }
  end

  def to_s
    "#{width}x#{height}"
  end
end
