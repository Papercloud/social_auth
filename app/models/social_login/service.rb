module SocialLogin
  class Service < ActiveRecord::Base
    #validations
    validates_presence_of :user_id, :access_token, :remote_id, :method
    validates_uniqueness_of :remote_id, scope: [:type], conditions: -> {where(method: 'Authenticated')}

    #relations
    belongs_to :user

    #settings
    self.table_name = "social_login_services"

    def self.init_with(auth_token)
        puts "need to overide"
    end

    def self.connect_with(user, auth_token)
    end

    # helper method to generate redis keys
    def redis_key(str)
      "#{type}:#{id}:#{str}"
    end

    def redis_instance

    end

  end
end