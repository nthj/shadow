class Asset < AWS::S3::S3Object
  begin
    set_current_bucket_to ENV['AMAZON_S3_DESTINATION_BUCKET']
    AWS::S3::Bucket.find current_bucket
  rescue
    AWS::S3::Bucket.create ENV['AMAZON_S3_DESTINATION_BUCKET'] or raise RuntimeError, "Could not create Asset bucket #{ENV['AMAZON_S3_DESTINATION_BUCKET']}"
    retry
  end
end
