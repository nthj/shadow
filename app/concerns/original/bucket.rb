class Original
  class Bucket < AWS::S3::Bucket
    set_current_bucket_to ENV['AMAZON_S3_SOURCE_BUCKET']
    
    class << self
      def all marker = nil, &block
        puts "Original Bucket is finding objects starting at marker: #{marker}"
        bucket  = find(:marker => marker)
        objects = bucket.objects.keep_if &:image?
        objects.each do |object|
          yield object
        end if block_given?
        objects = bucket.truncated? ? (objects & all(bucket.objects.last.key)) : objects # recursion ftw
        objects.sort_by do |original|
          Time.parse(original.last_modified).to_i
        end
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
