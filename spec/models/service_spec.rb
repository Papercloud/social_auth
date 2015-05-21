require 'spec_helper'

module SocialAuth

  describe Service do
    before :each do
      @user = User.create(email: "email@address.com")
      @redis_server = Redis.new
      allow_any_instance_of(Service).to receive(:redis_instance).and_return(@redis_server)
    end

    #service factories
    def valid_service(user)
      service = Service.create(access_token: {access_token: "34223"}, remote_id: "34343", user_id: user.id, method: "Authenticated")
    end

    it "has valid factory" do
      service = valid_service(User.create())
      expect(service).to be_valid
    end

    describe "associated_services" do
      it "includes service with whom your friends with" do
        service = Service.create(access_token: {fake: "fake"}, remote_id: "2", user: User.create, method: "Authenticated")
        expect(service).to receive(:friend_ids).and_return(["1234"])

        another_service = Service.create(access_token: {fake: "fake"}, remote_id: "1234", user: User.create, method: "Authenticated")
        expect(service.services).to include another_service
      end

      it "doesn't return service your not friends with" do
        service = Service.create(access_token: {fake: "fake"}, remote_id: "2", user: User.create, method: "Authenticated")
        expect(service).to receive(:friend_ids).and_return(["324"])

        another_service = Service.create(access_token: {fake: "fake"}, remote_id: "1234", user: User.create, method: "Authenticated")
        expect(service.services).to_not include another_service
      end
    end

    describe "append to friends list" do
      before :each do
        User.class_eval do
          def friend_joined_the_app_callback(user)
          end
        end
      end

      it "append to associate_services gets called on create" do
        expect_any_instance_of(Service).to receive(:append_to_associated_services).once
        service = Service.create(access_token: {fake: "fake"}, remote_id: "2", user: User.create, method: "Authenticated")
      end

      it "on create append remote_id to related services" do
        service = Service.create(access_token: {fake: "fake"}, remote_id: "2", user: User.create, method: "Authenticated")
        @redis_server.sadd(service.redis_key(:friends), ["10", "11"])

        expect(service.friend_ids.count).to eq 2

        another_service = Service.create(access_token: {fake: "fake"}, remote_id: "15", user: User.create, method: "Authenticated")
        @redis_server.sadd(another_service.redis_key(:friends), ["2"])

        Service.append_to_associated_services(another_service.id)

        expect(service.friend_ids.count).to eq 3
      end

      it "receives friend_join_the_app callback" do
        expect_any_instance_of(User).to receive(:friend_joined_the_app_callback)

        service = Service.create(access_token: {fake: "fake"}, remote_id: "2", user: User.create, method: "Authenticated")
        @redis_server.sadd(service.redis_key(:friends), ["10", "11"])

        expect(service.friend_ids.count).to eq 2

        another_service = Service.create(access_token: {fake: "fake"}, remote_id: "15", user: User.create, method: "Authenticated")
        @redis_server.sadd(another_service.redis_key(:friends), ["2"])

        Service.append_to_associated_services(another_service.id)
      end
    end

    describe "disconnect" do
      before :each do
        @service = Service.create(access_token: {access_token: "test"}, remote_id: "10204796229055532", user: @user, method: "Authenticated")
        User.class_eval do
          has_many :services, inverse_of: :user, class_name: SocialAuth::Service
          def service_disconnected_callback(service)
          end
        end
      end

      it "destroys service if 'Connected' service" do
        @service.update(method: 'Connected')
        expect{
          @service.disconnect
        }.to change(Service, :count).by(-1)
      end

      it "doesn't destroy service if 'Authenticated' service" do
        @service.update(method: 'Authenticated')
        expect{
          @service.disconnect
        }.to raise_error InvalidToken
      end

      it "hits service disconnected callback if callback is true" do
        @service.update(method: 'Connected')
        expect_any_instance_of(User).to receive(:service_disconnected_callback).once
        @service.disconnect
      end

      it "doesn't hit service disconnected callback if callback is false" do
        @service.update(method: 'Connected')
        expect_any_instance_of(User).to_not receive(:service_disconnected_callback).once
        @service.disconnect(nil, false)
      end
    end

    describe "disconnect_user" do
      before :each do
      end

      it "disconnects service belong to user" do
        service = Service.create(access_token: {access_token: "34223"}, remote_id: "34343", user: @user, method: "Connected")

        expect_any_instance_of(Service).to receive(:disconnect).once
        Service.disconnect_user(@user)
      end

      it "raises exception if you try to disconnect an authenticated service" do
        service = Service.create(access_token: {access_token: "34223"}, remote_id: "34343", user: @user, method: "Authenticated")

        expect{
          Service.disconnect_user(@user)
        }.to raise_error Error
      end

      it "raises exception if no service exists" do
        expect{
          Service.disconnect_user(@user)
        }.to raise_error ServiceDoesNotExist
      end
    end

    describe "validations" do
      before :each do
        @user = User.create
      end

      it "valid if 1 'Connected' of the same type exists for the same user" do
        service = Service.new(access_token: {access_token: "34223"}, remote_id: "34343", user: @user, method: "Connected")
        expect(service).to be_valid
      end

      it "invalid if more than 1 'Connected' of the same type exists for the same user"  do
        service = Service.create(access_token: {access_token: "34223"}, remote_id: "34343", user: @user, method: "Connected")
        other_service = Service.create(access_token: {access_token: "34223"}, remote_id: "34343", user: @user, method: "Connected")
        expect(other_service).to_not be_valid
      end

      xit "can't connect a service you have already authenticated with" do
      end

      it "can create 'Authenticated' service if 'Connected' service with same remote_id already exists" do
        service = Service.create(access_token: {access_token: "access_token"}, remote_id: "1", user: User.create, method: "Connected")
        other_service = Service.new(access_token: {access_token: "access_token"}, remote_id: "1", user: @user, method: "Authenticated")
        expect(other_service).to be_valid
      end

      it "'Connected' service is valid if another 'Authenticated' service exists with the same remote_id but for another user" do
        service = Service.create(access_token: {access_token: "access_token"}, remote_id: "1", user: User.create, method: "Authenticated")
        other_service = Service.new(access_token: {access_token: "access_token"}, remote_id: "1", user: @user, method: "Connected")
        expect(other_service).to be_valid
      end

      it "can have 1 authenticated service scoped remote_id" do
        service = Service.new(access_token: {access_token: "34223"}, remote_id: "34343", user: @user, method: "Authenticated")
        expect(service).to be_valid
      end

      it "cannot have multiple authenticate services with same remote_id" do
        service = Service.create!(access_token: {access_token: "fdf"}, remote_id: "34343", user: @user, method: "Authenticated")
        another_service = Service.new(access_token: {access_token: "fdf"}, remote_id: "34343", user: User.create, method: "Authenticated")
        expect(another_service).to_not be_valid
      end

      it "can have multiple connected services with same remote_id" do
        service = Service.create(access_token: {access_token: "fdf"}, remote_id: "34343", user: @user, method: "Connected")
        another_service = Service.create(access_token: {access_token: "fdf"}, remote_id: "34343", user: User.create, method: "Connected")
        expect(another_service).to be_valid
      end
    end

    describe "self.create_with_request" do
      def valid_service_from_request
        Service.create_with_request("1", @user, "Authenticated",{access_token: "access_token"})
      end

      it "creates an Authenticated method service if remote id doesn't exist" do
        expect{
          valid_service_from_request
        }.to change(Service, :count).by(1)
      end

      it "Can create a connected service even if an authenticated service belonging to another user already exists" do
        service = Service.create(access_token: {access_token: "access_token"}, remote_id: "1", user: User.create, method: "Authenticated")
        expect{
          Service.create_with_request("1", @user, "Connected", {access_token: "access_token"})
        }.to change(Service, :count).by(1)
      end

      it "creates service with type set to authenticated" do
        expect(valid_service_from_request.method).to eq "Authenticated"
      end

      it "creates service if connected service already exists but belonging to another user" do
        service = Service.create(access_token: {access_token: "access_token"}, remote_id: "1", user: @user, method: "Connected")
        expect{
          Service.create_with_request("1", User.create, "Connected", {access_token: "access_token"})
        }.to change(Service, :count).by(1)
      end

      it "returns service if remote_id and method is authenticated already exist" do
        service = Service.create(access_token: {access_token: "access_token"}, remote_id: "1", user: @user, method: "Authenticated")
        expect{
          expect(Service.create_with_request("1", @user, "Authenticated", {access_token: "access_token"})).to eq service
        }.to change(Service, :count).by(0)
      end

      it "returns service if no authenticate method exists however a single connected service does exist" do
        service = Service.create(access_token: {access_token: "access_token"}, remote_id: "1", user: @user, method: "Connected")
        expect{
          expect(Service.create_with_request("1", @user, "Authenticated", {access_token: "access_token"})).to eq service
        }.to change(Service, :count).by(0)
      end

      xit "raises exception if not authentication method exists however multiple connected services exist with the same remote_id" do
      end
    end

  end
end