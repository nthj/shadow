source 'http://rubygems.org'

gem 'aws-s3',                                   :require => 'aws/s3'
gem 'bson_ext'
gem 'compass'
gem 'fusion_tables'
gem 'geokit'
gem 'haml'
gem 'konpasu'
gem 'mongo_mapper',                             :git => 'git://github.com/jnunemaker/mongomapper.git'
gem 'pixel',                                    :git => 'git://github.com/nthj/pixel.git'
gem 'rails',                '~> 3'
gem 'railings',             '>= 0.0.4'
gem 'resque',               '>= 1.15'
gem 'resque-heroku-autoscaler'
gem 'rmagick',                                  :require => 'RMagick'
gem 'sprockets'

group :development do
  gem 'unicorn'
end

group :production do
  gem 'dalli'
  gem 'jsmin'
end

group :test do
  gem 'autotest-rails'
  gem 'autotest-fsevent'
  gem 'autotest-growl'
  gem 'autotest'
  gem 'rspec-rails',        '>= 2.0.0.beta.20'
end
