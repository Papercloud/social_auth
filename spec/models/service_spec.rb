require 'spec_helper'

module SocialLogin

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

      it "can have 1 authenticated service scoped remote_id" do
        service = Service.new(access_token: {access_token: "34223"}, remote_id: "34343", user: @user, method: "Authenticated")
        expect(service).to be_valid
      end

      it "cannot have multiple authenticate services with same remote_id" do
        service = Service.create(access_token: {access_token: "fdf"}, remote_id: "34343", user: @user, method: "Authenticated")
        another_service = Service.new(access_token: {access_token: "fdf"}, remote_id: "34343", user: @user, method: "Authenticated")
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