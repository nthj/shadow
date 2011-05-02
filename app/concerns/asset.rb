class Asset < AWS::S3::S3Object
  set_current_bucket_to ENV['AMAZON_S3_DESTINATION_BUCKET']
end
