require 'google_plus'

module SocialLogin
  class GooglePlusService < Service

    def self.init_with(auth_token={})
      request = create_connection(auth_token)

      return create_with_request(
        request.id,
        User.create_with_google_plus_request(request),
        "Authenticated",
        {access_token: auth_token[:access_token]}
      )
    end

    def self.connect_with(user, auth_token={})
      request = create_connection(auth_token)

      return create_with_request(
        request.id,
        user,
        "Connected",
        {access_token: auth_token[:access_token]}
      )
    end

    def self.create_connection(auth_token={})
      GooglePlus.access_token = auth_token[:access_token]
      GooglePlus::Person.get('me')
    rescue GooglePlus::RequestError => e
      raise InvalidToken.new(e.message)
    end
  end
end