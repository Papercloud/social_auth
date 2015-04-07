require 'spec_helper'

module SocialLogin

  describe GooglePlusService do
    before :each do
      @user = User.create(email: "email@address.com")
    end

    describe "social login methods" do
      it "receives init_with on authenticate" do
        expect(GooglePlusService).to receive(:init_with)
        SocialLogin.authenticate("google_plus", {access_token: "access_token"})
      end

      it "receives connect_with on connect" do
        expect(GooglePlusService).to receive(:connect_with)
        SocialLogin.connect(@user, "google_plus", {access_token: "access_token"})
      end
    end

    describe "self.init_with" do
      before :each do
        #create an override method on user which gets called whenever
        #we want a user created you do the rest!
        User.class_eval do
          has_many :services, inverse_of: :user, class_name: SocialLogin::Service
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
            GooglePlusService.connect_with(@user, {access_token: "wrong"})
          }.to raise_error InvalidToken
        end
      end
    end

    describe "create_connection" do
      it "returns valid connection" do
        VCR.use_cassette('google_plus_service/valid_request') do
          expect{
            GooglePlusService.create_connection(google_plus_access_token)
          }.to_not raise_error
        end
      end
    end
  end

end