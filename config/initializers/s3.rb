require Rails.root.join 'lib', 'aws', 's3', 'object'
require Rails.root.join 'app', 'concerns', 'extensions', 'object'

AWS::S3::Base.establish_connection!(
  :access_key_id      => ENV['AMAZON_ACCESS_KEY_ID'],
  :secret_access_key  => ENV['AMAZON_SECRET_ACCESS_KEY'],
  :persistent         => false
)

Object.justifiable_message_length = Original.processors.map(&:name).sort_by(&:length).first.length + 10
