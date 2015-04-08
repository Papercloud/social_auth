module SocialLogin
  module ActsAsSocialUser
    extend ActiveSupport::Concern

    included do
      after_commit :append_to_friends_lists, on: :create

      def append_to_friends

      end

      def friends_that_use_the_app
        remote_ids = services.map(&:friend_ids).flatten.map(&:to_s)
        self.class.joins(:services).where('social_login_services.remote_id IN (?)', remote_ids)
      end
    end

    module ClassMethods
      def acts_as_social_user(options = {})
        has_many :services, foreign_key: options[:foreign_key] || :user_id, class_name: SocialLogin::Service
      end
    end
  end
end