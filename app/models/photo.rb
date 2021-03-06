class Photo
  include MongoMapper::Document
  include Plugins::Benchmarkable
  include Plugins::Couriable
  include Plugins::Fusionable
  
  key :description,     String
  key :dimensions,      Dimensions
  key :etag,            String
  key :key,             Key
  key :last_modified,   Time
  key :orientation,     Orientation
  key :photographed_at, Time
  key :point,           Point
  key :published_at,    Time
  key :rating,          Rating
  key :tags,            Set,          :typecast => 'Tag'
  key :title,           String
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
  
  def eql? object
    return true if object.respond_to?(:etag) && object.etag == etag
    super
  end
  alias :== :eql?
  
  def key
    Key.from_mongo super # mongo_mapper key type is misbehaving
  end
  
  def original
    Original.find key
  end
  
  def publish!
    self.published_at = Time.now
    save
  end
  
  def title
    super || key.to_s.titleize
  end
end
