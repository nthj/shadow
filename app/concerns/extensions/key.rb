class Key < String
  EXTENSION = /\.((j(p|pe)|pn)g)$/i
  
  class << self
    def from_mongo value
      new value.to_s
    end
    
    def set_types_from_yaml yaml
      self.types = yaml.map(&:first) 
    end
    
    def set_types_from_yaml_file file
      set_types_from_yaml YAML::load_file file
    end
    
    def types= names
      names.each do |name|
        define_method name.to_sym do
          with name
        end unless new.respond_to? name.to_sym
      end
    end
  end
  
  def default *args
    clone.freeze
  end
  
  def exists?
    Asset.exists? self
  end
  
  def initialize value = ''
    replace value
  end
  
  def orphan
    self.class.new split('/').values_at(1..-1).join('/') if include?('/')
  end
  
  def own photographer
    self.class.new File.join(photographer, self)
  end
  
  def photographer
    split('/').first if include?('/')
  end
  
  def titleize
    File.basename(clone).titleize.gsub(EXTENSION, '')
  end
  
  def valid?
    self =~ EXTENSION
  end
  
  private
    alias method_missing default
    
  protected
    def with type
      clone.gsub(EXTENSION, "_#{type.to_s}.\\1").freeze
    end
end
