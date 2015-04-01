require "social_login/engine"

module SocialLogin
  def self.authenticate(type, request)
    case type.camelize
    when "Facebook"
      FacebookService.init_with(auth_token).user
    end
  end
end
