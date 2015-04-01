require 'spec_helper'

module SocialLogin

  describe FacebookService do
    before :each do
      @user = User.create(email: "email@address.com")
      allow_any_instance_of(FacebookService).to receive(:redis_instance).and_return(Redis.new)
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
      before :each do
        #create an override method on user which gets called whenever
        #we want a user created you do the rest!
        User.class_eval do
          has_many :services, inverse_of: :user, class_name: SocialLogin::Service
          def self.create_with_facebook_request(request)
            create
          end
        end
      end

      it "creates service if doesn't exist" do
        VCR.use_cassette('facebook_service/valid_request') do
          expect{
            FacebookService.init_with(fb_access_token)
          }.to change(FacebookService, :count).by(1)
        end
      end

      it "creates service with type set to authenticated" do
        VCR.use_cassette('facebook_service/valid_request') do
          expect(FacebookService.init_with(fb_access_token).method).to eq "Authenticated"
        end
      end

      it "returns service if remote_id and method is authenticated already exist" do
        service = FacebookService.create(access_token: "34223", remote_id: "10204796229055532", user: @user, method: "Authenticated")
        VCR.use_cassette('facebook_service/valid_request') do
          expect{
            expect(FacebookService.init_with(fb_access_token)).to eq service
          }.to change(FacebookService, :count).by(0)
        end
      end

      it "returns service if no authenticate method exists however a single connected service does exist" do
        service = FacebookService.create(access_token: "34223", remote_id: "10204796229055532", user: @user, method: "Connected")
        VCR.use_cassette('facebook_service/valid_request') do
          expect{
            expect(FacebookService.init_with(fb_access_token)).to eq service
          }.to change(FacebookService, :count).by(0)
        end
      end

      it "User receives override method" do
        expect(User).to receive(:create_with_facebook_request).once
        VCR.use_cassette('facebook_service/valid_request') do
          FacebookService.init_with(fb_access_token)
        end
      end

    end

    describe "self.connect_with" do
      it "creates service if doesn't exist" do
        VCR.use_cassette('facebook_service/valid_request') do
          expect{
            FacebookService.connect_with(@user, fb_access_token)
          }.to change(FacebookService, :count).by(1)
        end
      end

      it "creates authenticate service type" do
        VCR.use_cassette('facebook_service/valid_request') do
          expect(FacebookService.connect_with(@user, fb_access_token).method).to eq "Connected"
        end
      end

      it "returns service if does exist" do
        service = FacebookService.create(access_token: "34223", remote_id: "10204796229055532", user: @user, method: "Connected")
        VCR.use_cassette('facebook_service/valid_request') do
          expect{
            expect(FacebookService.connect_with(@user, fb_access_token)).to eq service
          }.to change(FacebookService, :count).by(0)
        end
      end
    end

    describe "friend_ids" do
      before :each do
        @service = FacebookService.create(access_token: fb_access_token, remote_id: "10204796229055532", user: @user, method: "Authenticated")
      end

      it "returns friend_ids" do
        VCR.use_cassette("facebook_service/valid_friends_request") do
          expect{
            expect(@service.friend_ids).to_not be_empty
          }.to_not raise_error
        end
      end
    end

  end
end