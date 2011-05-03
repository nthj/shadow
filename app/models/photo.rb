class Photo
  include MongoMapper::Document
  
  key :description,     String
  key :dimensions,      Dimensions
  key :etag,            String
  key :last_modified,   Time
  key :orientation,     Orientation
  key :photographed_at, Time
  key :point,           Point
  key :processing_time, Float
  key :published_at,    Time
  key :rating,          Rating
  key :tags,            Set,          :typecast => 'Tag'
  key :views,           Integer,      :default => 0
  
  timestamps!
  
  many :locations
  
  one :photographer
  
  ensure_index [['locations.coordinates', Mongo::GEO2D]]
  
  scope :geocodable,  'locations.geocoded_at' => nil
  scope :unrated,     :rating                 => nil

  scope :by_rating, ->(rating)  { where :rating => { '$gte' => rating } }
  scope :by_ratio,  ->(ratio)   { where 'dimensions.ratio' => ratio.query }
  scope :by_tag,    ->(tag)     { tag.blank? ? query : where(:tags => tag)  }
  scope :random,    ->          { skip(rand(count)) }
  
  class << self
    def last_processing_run
      if Photo.count.zero?
        Time.at(0)
      else
        Photo.sort(:last_modified.desc).first.last_modified || Time.at(0)
      end
    end
  end
  
  def benchmark seconds
    self.processing_time = seconds
    save
  end
  
  def clear!
    self.last_modified = nil
    save
  end
  
  def publish!
    self.published_at = Time.now
    save
  end
end
