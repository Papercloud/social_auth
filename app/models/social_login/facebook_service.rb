require 'fb_graph2'

module SocialLogin
  class FacebookService < Service
    FACEBOOK_CACHE = 2_592_000 # cache expiry in seconds

    def self.init_with(auth_token={})
      request = create_connection(auth_token)
      return create_with(request,
        User.create_with_facebook_request(request), "Authenticated")
    end

    def self.connect_with(user, auth_token={})
      return create_with(create_connection(auth_token), user, "Connected")
    end

    def self.create_with(request, user, method="Connected")
      unless service = find_by_remote_id_and_method(request.id, method)
        #attempts to look if some other user connected this same facebook account if its an authentication request
        if where(remote_id: request.id, method: "Connected").count == 1 and method == "Authenticated"
          service = find_by_remote_id_and_method(request.id, "Connected")
        else
          service = new
          service.remote_id = request.id
          service.user = user
          service.method = method
        end
      end

      service.access_token = {access_token: request.access_token}
      service.save

      return service
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