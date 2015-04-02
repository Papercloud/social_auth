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
    end

    def self.connect_with(user, auth_token={})
      request = create_connection(auth_token)

      return create_with_request(
        request.user.id,
        user,
        "Connected",
        {access_token: request.access_token, access_token_secret: request.access_token_secret}
      )
    end

    def self.create_connection(auth_token={})
      Twitter::REST::Client.new do |config|
        config.consumer_key        = "MxzWRgtXC2CVc71azEnN9u2Df"
        config.consumer_secret     = "QxNG8LukvzeAayj7igWazoUks9DtluNPn6D6Ej60bmu9z8uzM4"
        config.access_token        = auth_token[:access_token]
        config.access_token_secret = auth_token[:access_token_secret]
      end
    end

  end
end