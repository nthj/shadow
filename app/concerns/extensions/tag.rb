class Tag < Struct.new(:name, :count)
  class << self
    def available
      Photo.collection.map_reduce(map, reduce).find.sort('value.count', -1)
    end

    def cloud
      Rails.cache.fetch('tags.cloud', :expires_in => 1.hour) do
        available.sort('value.count', -1).limit(10).map do |tag|
          self.new(
            tag['_id'], 
            tag['value']['count'].to_i
          )
        end rescue Mongo::OperationFailure and return []
      end
    end

    def find name
      self.new name if ::Photo.by_tag(name).any?
    end
    
    def from_keywords keywords
      if keywords.respond_to?(:split)
        keywords.gsub(';', ',').split(',').map { |t| t.gsub(/([a-z]{3,8})\s[0-5]{1}/i, '\\1').strip }.uniq
      else
        []
      end
    end

    def page number = 1
      Rails.cache.fetch("tags.#{number}", :expires_in => 1.hour) do
        available.sort('_id').skip(number.to_i * 500 - 500).limit(500).map { |tag| 
          Tag.new(
          tag['_id'], 
          tag['value']['count'].to_i
          )
        }.delete_if(&:unpaginatable?) rescue Mongo::OperationFailure and return []
      end or raise MongoMapper::DocumentNotFound
    end

    def popular
      Rails.cache.fetch("tags.popular", :expires_in => 1.hour) do
        available.sort('value.count', -1).limit(100).map { |tag|
          Tag.new(
            tag['_id'], 
            tag['value']['count'].to_i
          )
        }.delete_if(&:unpopular?) rescue Mongo::OperationFailure and return []
      end
    end
    
    def to_mongo value
      value.to_s.downcase.parameterize '-'
    end
    
    protected
      def available
        ::Photo.collection.map_reduce(map, reduce).find
      end

      def map
        <<-json
          function()
          {
            this.tags.forEach(
              function(z)
              {
                emit( z , { count : 1, name : z } );
              }
            )
          }
        json
      end

      def reduce
        <<-json
          function( key , values )
          {
            var total = 0;
            for ( var i = 0; i < values.length; i++ )
            {
              total += values[i].count;
            }
            return { count : total };
          }
        json
      end
  end
  
  def photos
    ::Photo.published.by_tag(name).sort(:id.desc)
  end

  def to_s
    name.titleize
  end
  
  def unpaginatable?
    count < 3
  end
  
  def unpopular?
    count < 10
  end
end
