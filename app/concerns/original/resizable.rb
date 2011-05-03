class Original
  module Resizable
    @@methods = {
      :fill => :resize_to_fill!, 
      :fit  => :resize_to_fit!
    }
    
    @height = 0
    @width  = 0

    def method
      @method ||= @@methods.keys.first
      @@methods[@method]
    end
  
    def resize width, height, &block
      @width, @height = [width, height]
      self
    end
  
    def to m
      raise InvalidResizeToMethod, m.to_s unless @@methods.keys.include? m
      @method = m
      self
    end
  end
end
