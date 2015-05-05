module SocialAuth
  module ActsAsSocialUser
    extend ActiveSupport::Concern

    included do

      def friends_that_use_the_app
        self.class.joins(:services).where('social_auth_services.remote_id IN (?)', remote_ids)
      end

      def remote_ids
        remote_ids = services.map(&:friend_ids).flatten.map(&:to_s)
      end

    end

    module ClassMethods
      def acts_as_social_user(options = {})
        has_many :services, foreign_key: options[:foreign_key] || :user_id, class_name: SocialAuth::Service, dependent: :destroy
      end
    end
  end
end