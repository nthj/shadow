class Original
  module Savable
    attr_accessor :filters
    
    def initialize *args
      @filters = []
      super
    end
    
    def save as = :default
      quality = self.quality
      
      stream_to_temporary_file

      @image = ::Magick::Image.read(filename).first
      @image.strip! # goodbye EXIF
      @image.send method, @width, @height
      
      filters.each do |filter|
        filter.call key, @image
      end
      
      @image.write(filename) { |image| self.quality = quality unless quality.zero? }
      @image.destroy!
      
      log "Saving #{as}", key
      Asset.store key.send(as), open(filename), :access => :public_read
      
      log "Removing temporary file", key
      File.delete filename if File.exists? filename
      
      self
    end
  end
end
