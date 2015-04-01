require 'spec_helper'

module SocialLogin

  describe FacebookService do

    describe "social login methods" do
      before :each do
        @user = User.create(email: "email@address.com")
      end

      it "receives init_with on authenticate" do
        expect(FacebookService).to receive(:init_with)
        SocialLogin.authenticate("Facebook", "")
      end

      it "receives connect_with on connect" do
        expect(FacebookService).to receive(:connect_with)
        SocialLogin.authenticate("Facebook", @user)
      end
    end

    describe "self.init_with" do
      it "creates service if doesn't exist" do

      end
    end
  end
end