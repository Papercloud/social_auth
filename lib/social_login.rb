require "social_login/engine"
require 'sidekiq'

module SocialLogin
  extend ActiveSupport::Autoload

  autoload :ActsAsSocialUser, 'social_login/acts_as_social_user'

  mattr_accessor :redis_instance_method
  @@redis_instance_method = nil

  mattr_accessor :twitter_consumer_key
  @@twitter_consumer_key = nil

  mattr_accessor :twitter_consumer_secret
  @@twitter_consumer_secret = nil

  mattr_accessor :google_client_id
  @@google_client_id = nil

  mattr_accessor :google_client_secret
  @@google_client_secret = nil

  mattr_accessor :google_redirect_uri
  @@google_redirect_uri = nil

  mattr_accessor :google_api_key
  @@google_api_key = nil

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

  def self.disconect(user, type)
    case type.camelize
    when "Facebook"
      FacebookService.disconnect_user(user)
    when "Twitter"
      TwitterService.disconnect_user(user)
    when "GooglePlus"
      GooglePlusService.disconnect_user(user)
    end
  end
end

module ActiveRecord
  class Base
    include SocialLogin::ActsAsSocialUser
  end
end
