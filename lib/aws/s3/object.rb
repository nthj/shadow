module AWS
  module S3
    class S3Object
      class BucketFactory
        class << self
          def make object, bucket
            Class.new(AWS::S3::Bucket) do
              @object = object
              
              set_current_bucket_to bucket
              
              class << self
                attr_reader :object
                
                def all options = { }
                  log "Queueing 1,000/call", options[:marker]
                  bucket = find(current_bucket, options)
                  if bucket.truncated?
                    bucket.objects + all(options.merge!(:marker => bucket.objects.last.key)) # recursion ftw
                  else
                    bucket.objects
                  end
                end
                
                def name; 'Bucket'; end # AWS::S3::Response wants a name?  Smith.  Or Smitty, if you like.
              end

              def new_object attributes = { }
                self.class.object.new(attributes).tap do |object|
                  register(object)
                end
              end

              def truncated?
                attributes['is_truncated']
              end
            end
          end
        end
      end
      
      class << self        
        def find key
          # strip non-utf8 characters
          key    = key.remove_extended unless key.valid_utf8?
          bucket = self::ObjectBucket.find(:marker => key.previous, :max_keys => 1)
          if (object = bucket.objects.first) && object.key == key
            object 
          else 
            raise ::AWS::S3::NoSuchKey.new("No such key '#{key}'", bucket)
          end
        end

        def first
          self::ObjectBucket.find(:max_keys => 1).first
        end
      
        alias set_current_bucket_to_without_object_bucket set_current_bucket_to
        def set_current_bucket_to bucket
          self.const_set 'ObjectBucket', BucketFactory.make(self, bucket)
          set_current_bucket_to_without_object_bucket(bucket)
        end
      end
    end
  end
end
