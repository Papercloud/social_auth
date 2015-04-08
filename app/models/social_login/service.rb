module SocialLogin
  class Service < ActiveRecord::Base
    #validations
    validates_presence_of :user, :access_token, :remote_id, :method
    validates_uniqueness_of :remote_id, scope: [:type], conditions: -> {where(method: 'Authenticated')}
    before_validation :validate_methods

    #relations
    belongs_to :user

    #settings
    self.table_name = "social_login_services"

    #callbacks
    after_create :append_to_associated_services

    ACCEPTED_METHODS = %w(Authenticated Connected)
    REDIS_CACHE = 2_592_000 # cache expiry in seconds

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

    def self.create_with_request(remote_id, user, method="Connected", access_token={})
      remote_id = remote_id.to_s
      unless service = find_by_remote_id_and_method(remote_id, method)
        #attempts to look if some other user connected this same facebook account if its an authentication request
        if count = where(remote_id: remote_id, method: "Connected").count == 1 and method == "Authenticated"
          service = find_by_remote_id_and_method(remote_id, "Connected")
        else
          service = new
          service.remote_id = remote_id

          #gives the owner one last chance to perform some app level logic on the user before being created
          user = user.validate_existing_user(remote_id, service.type) if user.respond_to?(:validate_existing_user)
          service.user = user
          service.method = method
        end
      end

      service.access_token = access_token
      service.save

      return service
    end

    def services
      self.class.where('remote_id IN (?) and type = ?', friend_ids, type)
    end

    def self.append_to_associated_services(id)
      service = find(id)
      service.services.each do |s|
        s.append_to_friends_list(service.remote_id)
      end
    end

    def append_to_friends_list(remote_id)
      if redis_instance.exists(self.redis_key(:friends))
        redis_instance.sadd(self.redis_key(:friends), remote_id)
      end
    end

    def friend_ids
      if redis_instance.exists(redis_key(:friends))
        friend_ids = redis_instance.smembers(redis_key(:friends))
      else
        []
      end
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

    private

    def append_to_associated_services
      self.class.delay.append_to_associated_services(self.id)
    end

  end

  #exceptions
  class InvalidToken < StandardError ; end
  class BadRequest < StandardError ; end
  class MultipleConnectedAccounts < StandardError ; end

end