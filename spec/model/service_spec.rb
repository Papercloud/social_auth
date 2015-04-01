require 'spec_helper'

module SocialLogin
  describe Service do
    it "has valid factory" do
      service = build(:service)
      expect(service).to be_valid
    end

    before :each do

    end

    it "hello" do
      puts "hello!"
    end
  end
end