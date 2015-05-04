SocialAuth.setup do |config|
  config.redis_instance_method = :redis_instance_var #eg $redis

  config.twitter_consumer_key = ENV['TWITTER_CONSUMER_KEY']

  config.twitter_consumer_secret = ENV['TWITTER_CONSUMER_SECRET']

  config.google_client_id = ENV['GOOGLE_CLIENT_ID']

  config.google_client_secret = ENV['GOOGLE_CLIENT_SECRET']

  config.google_redirect_uri = ENV['GOOGLE_REDIRECT_URI']

  config.google_api_key = ENV['GOOGLE_API_KEY']
end