class PostalCode < String
  class << self
    def from_mongo value
      self.new value
    end

    def to_mongo value
      value.to_s.gsub(/[^0-9\-]/, '').length > 0 ? value.gsub(/[^0-9\-]/, '') : nil
    end
  end

  def initialize value
    replace value.gsub(/[^0-9\-]/, '') unless value.nil?
  end
end
