require "social_login/engine"

module SocialLogin

  mattr_accessor :redis_instance_method
  @@redis_instance_method = nil

  # Used to set up Social Login from the initializer.
  def self.setup
    yield self
  end

  def self.authenticate(type, auth_token)
    case type.camelize
    when "Facebook"
      FacebookService.init_with(auth_token)
    when "Twitter"
      TwitterService.init_with(auth_token)
    end
  end

  def self.connect(user, type, auth_token)
    case type.camelize
    when "Facebook"
      FacebookService.connect_with(user, auth_token)
    when "Twitter"
      TwitterService.connect_with(user, auth_token)
    end
  end
end
