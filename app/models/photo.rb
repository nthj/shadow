class Photo
  include MongoMapper::Document
  
  key :description,     String
  key :dimensions,      Dimensions
  key :orientation,     Orientation
  key :photographed_at, Time
  key :point,           Point
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
end
