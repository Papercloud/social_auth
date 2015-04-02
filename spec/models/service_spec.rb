require 'spec_helper'

module SocialLogin

  describe Service do

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

    #service factories
    def valid_service(user)
      service = Service.create(access_token: {access_token: "34223"}, remote_id: "34343", user_id: user.id, method: "Authenticated")
    end

    it "has valid factory" do
      service = valid_service(User.create())
      expect(service).to be_valid
    end

  end
end