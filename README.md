# Contests web application

This is a web application to manage contests, user's login/registration and participation in contests uploading audios.

## Version 2

* Built on Ruby and Ruby on Rails.
* Bootstrap as a front-end framework.
* Integrated with AWS.
* Uses AWS S3 to store images and audios.
* Uses AWS ElastiCache to store session data.
* Uses AWS CloudFront as a CDN.
* Uses AWS SQS to put messages in the queue. The batch/worker is responsible to process those messages.
* Uses MongoDB, a no-relational database.

## Assumptions

This application was created using:

* Ruby 2.5.3
* Rails 5.2.2
* Ubuntu 18.4
* Mongo 4.1.9

## Prerequisites

1) Install Ruby on Rails, follow this [link](https://gorails.com/setup/ubuntu/18.04).
2) Install Git, follow this [link](https://www.liquidweb.com/kb/install-git-ubuntu-16-04-lts/).
3) Install Mongo, follow this [link](https://www.digitalocean.com/community/tutorials/how-to-install-mongodb-on-ubuntu-18-04).

## Instructions

1) Configure these environment variables:

|Environment variable|Example|Description|
|-|-|-|
|`CONTESTS_SERVER_URL`|http://localhost:8000/|The server URL where web application is deployed|
|`CONTESTS_DATABASE_HOST`|localhost or 127.0.0.1|The database host|
|`CONTESTS_DATABASE_USER`|root|The database user|
|`CONTESTS_DATABASE_PASSWORD`|12345|The database password|
|`CONTESTS_DATABASE_NAME`|contests|The database name|
|`CONTESTS_PATH_IMAGES`|/home/images/|The path for images|
|`CONTESTS_PATH_ORIGINAL_FILES`|/home/audio/original/|The path where *ORIGINAL* audio files will be stored|
|`CONTESTS_PATH_CONVERTED_FILES`|/home/audio/converted/|The path where *CONVERTED* audio files will be stored|
|`CONTESTS_REDIS_URL`|redis://localhost:6379/contests|The redis server. This environment variable has no value by default|
|`AWS_ACCESS_KEY_ID`|-|The AWS key ID for AWS S3 service|
|`AWS_SECRET_ACCESS_KEY`|-|The AWS access key for AWS S3 service|
|`AWS_REGION`|-|The AWS region for AWS S3 service|
|`CONTESTS_AWS_BUCKET`|local-test-s3|The S3 bucket name|
|`CONTESTS_TEMPORAL_DIRECTORY`|/home/temporal/|Path to save temporal images and audios before to upload those to S3|
|`CONTESTS_CLOUD_FRONT_HOST`|http://d2gkjvj8romr3p.cloudfront.net/|CloudFront host|
|`CONTESTS_SQS_URL`|https://sqs.us-east-1.amazonaws.com/470416846005/local-test-sqs.fifo|AWS SQS URL|

2) Go to `bin/` folder.

3) Install all the necessary gems and update the existing ones:

```bash
gem update
gem install rails
bundle install
```

4) Run the server:

```bash
rails server -p 8000
```

5) Go to your favorite web browser and type:

```bash
http://localhost:8000/
```

6) Enjoy.
