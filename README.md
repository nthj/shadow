Shadow is an AWS S3 image processing application that runs on Heroku.

Given an S3 bucket, Shadow processes approximately 11,000 photos an hour: 

* resizing, 
* watermarking, and 
* extracting EXIF data

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
