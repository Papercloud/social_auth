require 'google_plus'

module SocialLogin
  class GooglePlusService < Service

    def self.init_with(auth_token={})
      request = create_connection(auth_token).get('me')

      return create_with_request(
        request.id,
        User.create_with_google_plus_request(request),
        "Authenticated",
        {access_token: auth_token[:access_token]}
      )
    rescue GooglePlus::RequestError => e
      raise InvalidToken.new(e.message)
    end

    def self.connect_with(user, auth_token={})
      request = create_connection(auth_token).get('me')

      return create_with_request(
        request.id,
        user,
        "Connected",
        {access_token: auth_token[:access_token]}
      )
    rescue GooglePlus::RequestError => e
      raise InvalidToken.new(e.message)
    end

    def self.create_connection(auth_token={})
      GooglePlus.access_token = auth_token[:access_token]
      GooglePlus::Person
    end

    def friend_ids
      if redis_instance.exists(redis_key(:friends))
        friend_ids = redis_instance.smembers(redis_key(:friends))
      else
        friend_ids = self.class.create_connection(access_token).list.items.map(&:id)
        unless friend_ids.empty?
          redis_instance.del(redis_key(:friends))
          redis_instance.sadd(redis_key(:friends), friend_ids)
          redis_instance.expire(redis_key(:friends), REDIS_CACHE)
        end
      end
      friend_ids
    end
  end
end