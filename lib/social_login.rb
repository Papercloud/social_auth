require "social_login/engine"

module SocialLogin
  def self.authenticate(type, auth_token)
    case type.camelize
    when "Facebook"
      FacebookService.init_with(auth_token)
    end
  end

  def self.connect(user, type, auth_token)
    case type.camelize
    when "Facebook"
      FacebookService.connect_with(user, type, auth_token)
    end
  end
end
