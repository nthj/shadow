Shadow is an AWS S3 image processing application that runs on Heroku.

Given an S3 bucket, Shadow processes approximately 11,000 photos an hour: 

* resizing, 
* watermarking, and 
* extracting EXIF data

See it in action at http://maps.abovephotography.com.au - over 30,000 photos processed and counting.

SETUP
=====

After you've cloned the repository locally, run `rake setup` to start the wizard.
Here is a list of credentials Shadow will ask you for:

* Amazon access key ID
* Amazon secret access key
* S3 source bucket (where your originals or masters reside)
* S3 destination bucket (where Shadow will place your processed photos)
* Google Maps API key (for geocoding your photos)
* Heroku API key (for automatically scaling your workers)

Additionally, Shadow expects you to have a Heroku (http://heroku.com) account, 
and will ask to install the following free add-ons into your app:

* Memcached
* MongoHQ
* Redis To Go

CONFIGURATION
=============

By default, you have several processors...

* Change Showcase dimensions in app/concerns/processors/showcaser.rb
* Change out the watermark in config/watermark.png
* Change Previewer dimensions (thumbnail dimensions) in app/concerns/processors/previewer.rb

USAGE
=====

To get started, you'll probably want to queue up photos to be processed: 

	heroku rake photos:queue
	
Note on Patches/Pull Requests
=============================

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don’t break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Copyright
=========

Copyright © 2011 Nathaniel Jones. See LICENSE for details.
