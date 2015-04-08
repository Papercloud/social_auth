require "social_login/engine"
require 'sidekiq'

module SocialLogin
  extend ActiveSupport::Autoload

  autoload :ActsAsSocialUser, 'social_login/acts_as_social_user'

  mattr_accessor :redis_instance_method
  @@redis_instance_method = nil

  mattr_accessor :twitter_consumer_key
  @@redis_instance_method = nil

  mattr_accessor :twitter_consumer_secret
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
    when "GooglePlus"
      GooglePlusService.init_with(auth_token)
    end
  end

  def self.connect(user, type, auth_token, method="Connected")
    case type.camelize
    when "Facebook"
      FacebookService.connect_with(user, auth_token, method)
    when "Twitter"
      TwitterService.connect_with(user, auth_token, method)
    when "GooglePlus"
      GooglePlusService.connect_with(user, auth_token, method)
    end
  end
end

module ActiveRecord
  class Base
    include SocialLogin::ActsAsSocialUser
  end
end
