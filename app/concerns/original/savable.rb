class Original
  module Savable
    attr_accessor :filters
    
    def initialize *args
      @filters = []
      super
    end
    
    def save as = :default
      quality = self.quality
            
      image.strip! # goodbye EXIF
      
      image.send method, @width, @height
      
      filters.each do |filter|
        filter.call key, image
      end
      
      image.write(filename) { |image| self.quality = quality unless quality.zero? }
      
      notify "Saving #{as}", key
      Asset.store key.send(as), open(filename), :access => :public_read
      
      notify "Removing temporary file", key
      File.delete filename if File.exists? filename
      
      self
    end
  end
end
