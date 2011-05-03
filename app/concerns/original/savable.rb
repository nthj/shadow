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
        filter.call @image
      end
      
      @image.write(filename) { |image| self.quality = quality unless quality.zero? }
      @image.destroy!
      
      puts "Saving #{as}...".ljust(original.justifiable) + key
      Asset.store key.send(as), open(filename), :access => :public_read
      
      puts "Removing temporary file...".ljust(original.justifiable) + key
      File.delete filename if File.exists? filename
      
      self
    end
  end
end
