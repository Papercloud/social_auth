require 'fb_graph2'

module SocialLogin
  class FacebookService < Service

    def self.init_with(auth_token)
      #creates facebook user if not found
      user = FbGraph2::User.me(auth_token)
      request = user.fetch

      unless service = find_by_remote_id(request.id)
        service = new
        service.remote_id = request.id
        service.user = User.create #pass a method back to user
        service.method = "Authenticated"
      end

      service.access_token = request.access_token
      service.save

      return service

    # rescue FbGraph2::Exception::InvalidToken => e
    end

    def self.connect_with(user, type, auth_token)

    end

  end
end