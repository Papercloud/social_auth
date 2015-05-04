require 'twitter'

module SocialAuth
  class TwitterService < Service

    def name
      "Twitter"
    end

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
        config.consumer_key        = SocialAuth.twitter_consumer_key
        config.consumer_secret     = SocialAuth.twitter_consumer_secret
        config.access_token        = auth_token[:access_token]
        config.access_token_secret = auth_token[:access_token_secret]
      end
      #the reason why we don't catch any exceptions here is because it only initializes the connection no
      #requests are actually made here
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
    rescue Twitter::Error::Unauthorized => e
      disconnect
      return []
    end

  end
end