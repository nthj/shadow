class Ratio
  class << self
    def calculate height, width
      if width.to_i.zero?
        new 0.0
      else
        new height.to_f / width.to_f
      end
    end
  end
  
  attr_reader :ratio
  alias to_f ratio
  
  def initialize ratio, within = 0.0
    @ratio  = ratio
    @within = within
  end
  
  def query
    { 
      '$gte' => @ratio - @within,
      '$lte' => @ratio + @within
    }
  end
end

