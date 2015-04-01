require 'spec_helper'

module SocialLogin

  describe FacebookService do
    before :each do
      @user = User.create(email: "email@address.com")
    end

    describe "social login methods" do
      it "receives init_with on authenticate" do
        expect(FacebookService).to receive(:init_with)
        SocialLogin.authenticate("Facebook", "access_token")
      end

      it "receives connect_with on connect" do
        expect(FacebookService).to receive(:connect_with)
        SocialLogin.connect(@user, "Facebook", "access_token")
      end
    end

    describe "self.init_with" do

      it "creates service if doesn't exist" do
        VCR.use_cassette('facebook_service/valid_request') do
          expect{
            SocialLogin.authenticate("Facebook", fb_access_token)
          }.to change(FacebookService, :count).by(1)
        end
      end

      it "returns service if does exist" do
        service = FacebookService.create(access_token: "34223", remote_id: "10204796229055532", user: @user, method: "Authenticated")
        VCR.use_cassette('facebook_service/valid_request') do
          expect{
            expect(SocialLogin.authenticate("Facebook", fb_access_token)).to eq service
          }.to change(FacebookService, :count).by(0)
        end
      end

    end
  end
end