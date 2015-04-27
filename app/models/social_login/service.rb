module SocialLogin
  class Service < ActiveRecord::Base
    #validations
    validates_presence_of :user, :access_token, :remote_id, :method
    validates_uniqueness_of :remote_id, scope: [:type], :if => lambda { |service| service.method == 'Authenticated' }
    validates_uniqueness_of :remote_id, scope: [:type, :user_id], :if => lambda { |service| service.method == 'Connected' }

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

      unless (service = find_by_remote_id_and_method(remote_id, method)) && method == "Authenticated"
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
        s.append_to_friends_list(service)
      end
    end

    def append_to_friends_list(service)
      if redis_instance.exists(self.redis_key(:friends))
        redis_instance.sadd(self.redis_key(:friends), service.remote_id)
      end
      user.friend_joined_the_app_callback(service.user) if user.respond_to?(:friend_joined_the_app_callback)
    end

    def friend_ids
      if redis_instance.exists(redis_key(:friends))
        friend_ids = redis_instance.smembers(redis_key(:friends))
      else
        []
      end
    end

    def self.disconnect_user(user)
      service = find_by_user_id(user.id)
      if service
        raise Error.new("Cannot disconnect a service you used to authenticate with") if service.authenticated?

        service.disconnect(false)
      else
        raise ServiceDoesNotExist.new("Couldn't find service for this user")
      end
    end

    def disconnect(callback=true)
      #destroys service
      self.destroy if method == 'Connected'
      #notifies the user that their service is about to be disconnected
      user.service_disconnected_callback(self) if user.respond_to?(:service_disconnected_callback) and callback
    end

    # helper method to generate redis keys
    def redis_key(str)
      "#{type}:#{id}:#{str}"
    end

    def redis_instance
      $redis
    end

    def authenticated?
      return true if method == 'Authenticated'
      false
    end

    def connected?
      return true if method == 'Connected'
      false
    end

    private

    def validate_methods
      errors.add(:method, 'not an accepted option') unless ACCEPTED_METHODS.include?(method)
    end

    def append_to_associated_services
      self.class.delay.append_to_associated_services(self.id)
    end

  end

  #exceptions
  class InvalidToken < StandardError ; end
  class BadRequest < StandardError ; end
  class MultipleConnectedAccounts < StandardError ; end
  class ServiceDoesNotExist < StandardError ; end
  class Error < StandardError ; end

end