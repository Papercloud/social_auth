module SocialLogin
  class Service < ActiveRecord::Base
    #validations
    validates_presence_of :user_id, :access_token, :remote_id, :method
    validates_uniqueness_of :remote_id, scope: [:type], conditions: -> {where(method: 'Authenticated')}

    #relations
    belongs_to :user

    #settings
    self.table_name = "social_login_services"

    def self.init_with(request)

    end

  end
end