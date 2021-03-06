require 'spec_helper'

module SocialAuth

  describe GooglePlusService do
    before :each do
      @user = User.create(email: "email@address.com")
      allow_any_instance_of(GooglePlusService).to receive(:redis_instance).and_return(Redis.new)
      allow_any_instance_of(GooglePlusService).to receive(:append_to_associated_services).and_return(true)
      SocialAuth.google_client_id = "1053743633063-aaearku9rl008rc8vq7muvreifc4jbo8.apps.googleusercontent.com"
      SocialAuth.google_client_secret = "rK6Fkmo6qpiiy0_SnWJDOlgv"
      SocialAuth.google_redirect_uri = "https://developers.google.com/oauthplayground"
      SocialAuth.google_api_key = "AIzaSyAKMHRoLKyRo5rivF8hq_Ic3SmvphBYIBk"
    end

    describe "social login methods" do
      it "receives init_with on authenticate" do
        expect(GooglePlusService).to receive(:init_with)
        SocialAuth.authenticate("google_plus", {access_token: "access_token"})
      end

      it "receives connect_with on connect" do
        expect(GooglePlusService).to receive(:connect_with)
        SocialAuth.connect(@user, "google_plus", {access_token: "access_token"})
      end
    end

    describe "self.init_with" do
      before :each do
        #create an override method on user which gets called whenever
        #we want a user created you do the rest!
        User.class_eval do
          has_many :services, inverse_of: :user, class_name: SocialAuth::Service
          def self.create_with_google_plus_request(request)
            new
          end
        end
      end

      it "creates service if doesn't exist" do
        VCR.use_cassette('google_plus_service/valid_request') do
          expect{
            GooglePlusService.init_with(google_plus_access_token)
          }.to change(GooglePlusService, :count).by(1)
        end
      end

      it "User receives override method" do
        expect(User).to receive(:create_with_google_plus_request).once
        VCR.use_cassette('google_plus_service/valid_request') do
          GooglePlusService.init_with(google_plus_access_token)
        end
      end
    end

    describe "self.connect_with" do
      it "creates service if doesn't exist" do
        VCR.use_cassette('google_plus_service/valid_request') do
          expect{
            GooglePlusService.connect_with(@user, google_plus_access_token)
          }.to change(GooglePlusService, :count).by(1)
        end
      end

      it "invalid_token raises InvalidToken exception" do
        VCR.use_cassette('google_plus_service/invalid_token') do
          expect{
            GooglePlusService.connect_with(@user, {auth_token: "wrong"})
          }.to raise_error InvalidToken
        end
      end
    end

    describe "create_connection" do
      it "fetches token correctly" do
        VCR.use_cassette("google_plus_service/valid_authorization") do
          response = GooglePlusService.fetch_access_token({auth_token: google_plus_auth_token})
          expect(response[:refresh_token]).to be_present
        end
      end

      it "fetches token correctly" do
        VCR.use_cassette("google_plus_service/invalid_authorization") do
          expect{
            GooglePlusService.fetch_access_token({auth_token: "bad-token"})
          }.to raise_error InvalidToken
        end
      end

      it "returns valid connection" do
        VCR.use_cassette('google_plus_service/valid_request') do
          expect{
            GooglePlusService.create_connection(google_plus_access_token)
          }.to_not raise_error
        end
      end
    end

    describe "friend_ids" do
      before :each do
        @service = GooglePlusService.create(access_token: {refresh_token:  google_plus_access_token[:refresh_token]}, remote_id: "410739240", user: @user, method: "Authenticated")
      end

      it "returns friend_ids" do
        VCR.use_cassette("google_plus_service/valid_friends_request") do
          expect{
            expect(@service.friend_ids).to_not be_empty
          }.to_not raise_error
        end
      end

      it "doesn't raise error if user has no friends" do
        expect_any_instance_of(GooglePlusService).to receive(:google_items).and_return(nil)
        VCR.use_cassette("google_plus_service/valid_friends_request") do
          expect{
            expect(@service.friend_ids).to be_empty
          }.to_not raise_error
        end
      end

      it "invalid_token returns empty array and hits disconnect callback" do
        service = GooglePlusService.create(access_token: {refresh_token: "fake"}, remote_id: "410739240", user: @user, method: "Authenticated")
        expect_any_instance_of(GooglePlusService).to receive(:disconnect).once
        VCR.use_cassette("google_plus_service/invalid_friends_request") do
          expect{
            expect(service.friend_ids).to be_empty
          }.to_not raise_error
        end
      end
    end
  end

end