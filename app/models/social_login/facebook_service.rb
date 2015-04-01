require 'fb_graph2'

module SocialLogin
  class FacebookService < Service
    FACEBOOK_CACHE = 2_592_000 # cache expiry in seconds

    def self.init_with(auth_token)
      #creates facebook user if not found
      fb_user = FbGraph2::User.me(auth_token)
      request = fb_user.fetch

      unless service = find_by_remote_id(request.id)
        service = new
        service.remote_id = request.id
        service.user = User.create #pass a method back to user to create eg. User.create_with_facebook(request)
        service.method = "Authenticated"
      end

      service.access_token = request.access_token
      service.save

      return service
    end

    def self.connect_with(user, auth_token)
      fb_user = FbGraph2::User.me(auth_token)
      request = fb_user.fetch

      unless service = find_by_remote_id(request.id)
        service = new
        service.remote_id = request.id
        service.user = user
        service.method = "Connected"
      end

      service.access_token = request.access_token
      service.save

      return service
    end

    def friend_ids
      if redis_instance.exists(redis_key(:friends))
        friend_ids = redis_instance.smembers(redis_key(:friends))
      else
        fb_user = FbGraph2::User.new('me').authenticate(access_token)
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