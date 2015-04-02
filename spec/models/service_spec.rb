require 'spec_helper'

module SocialLogin

  describe Service do
    before :each do
      @user = User.create(email: "email@address.com")
    end

    #service factories
    def valid_service(user)
      service = Service.create(access_token: {access_token: "34223"}, remote_id: "34343", user_id: user.id, method: "Authenticated")
    end

    it "has valid factory" do
      service = valid_service(User.create())
      expect(service).to be_valid
    end

    describe "validations" do
      before :each do
        @user = User.create
      end

      it "can have 1 authenticated service scoped remote_id" do
        service = Service.new(access_token: {access_token: "34223"}, remote_id: "34343", user: @user, method: "Authenticated")
        expect(service).to be_valid
      end

      it "cannot have multiple authenticate services with same remote_id" do
        service = FacebookService.create(access_token: {access_token: "fdf"}, remote_id: "34343", user: @user, method: "Authenticated")
        another_service = FacebookService.new(access_token: {access_token: "fdf"}, remote_id: "34343", user: @user, method: "Authenticated")
        expect(another_service).to_not be_valid
      end

      it "can have multiple connected services with same remote_id" do
        service = FacebookService.create(access_token: {access_token: "fdf"}, remote_id: "34343", user: @user, method: "Connected")
        another_service = FacebookService.new(access_token: {access_token: "fdf"},remote_id: "34343", user: @user, method: "Connected")
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