SocialLogin.setup do |config|
  config.redis_instance_method = :redis_instance_var #eg $redis

  config.twitter_consumer_key = ENV['TWITTER_CONSUMER_KEY']

  config.twitter_consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
end