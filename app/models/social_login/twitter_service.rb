require 'twitter'

module SocialLogin
  class TwitterService < Service

    def self.init_with(auth_token={})
      request = create_connection(auth_token)

      return create_with_request(
        request.user.id,
        User.create_with_twitter_request(request.user),
        "Authenticated",
        {access_token: request.access_token, access_token_secret: request.access_token_secret}
      )

    rescue Twitter::Error::Unauthorized => e
      raise InvalidToken.new(e.message)
    end

    def self.connect_with(user, auth_token={}, method="Connected")
      request = create_connection(auth_token)

      return create_with_request(
        request.user.id,
        user,
        method,
        {access_token: request.access_token, access_token_secret: request.access_token_secret}
      )

    rescue Twitter::Error::Unauthorized => e
      raise InvalidToken.new(e.message)
    end

    def self.create_connection(auth_token={})
      Twitter::REST::Client.new do |config|
        config.consumer_key        = SocialLogin.twitter_consumer_key
        config.consumer_secret     = SocialLogin.twitter_consumer_secret
        config.access_token        = auth_token[:access_token]
        config.access_token_secret = auth_token[:access_token_secret]
      end
    end

    def friend_ids
      if redis_instance.exists(redis_key(:friends))
        friend_ids = redis_instance.smembers(redis_key(:friends))
      else
        friend_ids = self.class.create_connection(access_token).friend_ids.to_hash[:ids].map(&:to_s)
        unless friend_ids.empty?
          redis_instance.del(redis_key(:friends))
          redis_instance.sadd(redis_key(:friends), friend_ids.to_s)
          redis_instance.expire(redis_key(:friends), REDIS_CACHE)
        end
      end
      friend_ids
    end

  end
end