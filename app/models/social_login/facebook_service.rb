require 'fb_graph2'

module SocialLogin
  class FacebookService < Service
    FACEBOOK_CACHE = 2_592_000 # cache expiry in seconds

    def self.init_with(auth_token={})
      request = create_connection(auth_token)

      return create_with_request(
        request.id,
        User.create_with_facebook_request(request),
        "Authenticated",
        {access_token: request.access_token}
      )
    end

    def self.connect_with(user, auth_token={})
      request = create_connection(auth_token)

      return create_with_request(
        request.id,
        user,
        "Connected",
        {access_token: request.access_token}
      )
    end

    def self.create_connection(auth_token={})
      fb_user = FbGraph2::User.me(auth_token[:access_token])
      fb_user.fetch

    rescue FbGraph2::Exception::InvalidToken => e
      raise InvalidToken.new(e.message)
    rescue FbGraph2::Exception::BadRequest => e
      raise BadRequest.new(e.message)
    end

    def friend_ids
      if redis_instance.exists(redis_key(:friends))
        friend_ids = redis_instance.smembers(redis_key(:friends))
      else
        fb_user = FbGraph2::User.new('me').authenticate(access_token[:access_token])
        friend_ids = fb_user.friends.map(&:id)
        unless friend_ids.empty?
          redis_instance.del(redis_key(:friends))
          redis_instance.sadd(redis_key(:friends), friend_ids)
          redis_instance.expire(redis_key(:friends), FACEBOOK_CACHE)
        end
      end
      friend_ids
    end

  end
end