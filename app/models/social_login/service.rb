module SocialLogin
  class Service < ActiveRecord::Base
    #validations
    validates_presence_of :user_id, :access_token, :remote_id, :method
    validates_uniqueness_of :remote_id, scope: [:type], conditions: -> {where(method: 'Authenticated')}
    before_validation :validate_methods

    #relations
    belongs_to :user

    #settings
    self.table_name = "social_login_services"

    ACCEPTED_METHODS = %w(Authenticated Connected)

    def access_token
      if super.blank?
        {}
      else
        super.with_indifferent_access
      end
    end

    def self.init_with(auth_token)
      raise "need to override"
    end

    def self.connect_with(user, auth_token)
      raise "need to override"
    end

    # helper method to generate redis keys
    def redis_key(str)
      "#{type}:#{id}:#{str}"
    end

    def redis_instance
      $redis
    end

    private

    def validate_methods
      errors.add(:method, 'not an accepted option') unless ACCEPTED_METHODS.include?(method)
    end

  end
end