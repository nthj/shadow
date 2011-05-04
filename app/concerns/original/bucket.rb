class Original
  class Bucket < AWS::S3::Bucket
    set_current_bucket_to ENV['AMAZON_S3_SOURCE_BUCKET']
    
    class << self
      def all options = { }
        puts "Queueing 1,000/call...".ljust(Original.justifiable + 10) + options[:marker].to_s
        bucket  = find(options)
        bucket.truncated? ? (bucket.objects + all(options.merge!(:marker => bucket.objects.last.key))) : bucket.objects # recursion ftw
      end
    end
    
    def new_object attributes = { }
      ::Original.new(attributes).tap do |object|
        register(object)
      end
    end
    
    def truncated?
      attributes['is_truncated']
    end
  end
end
