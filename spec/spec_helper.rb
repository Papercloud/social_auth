$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH << File.expand_path('../support', __FILE__)

# Use Rails 4 by default if you just do 'rspec spec'
ENV['BUNDLE_GEMFILE'] ||= 'gemfiles/rails42.gemfile'

ENV['BUNDLE_GEMFILE'] = File.expand_path(ENV['BUNDLE_GEMFILE'])
require "bundler"
Bundler.setup

ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] = File.expand_path("../dummy/rails-#{ENV['RAILS_VERSION']}", __FILE__)

# Create the test app if it doesn't exists
unless File.exists?(ENV['RAILS_ROOT'])
  puts "creating rails app #{ENV['RAILS_ROOT']}"
  system 'rake setup'
end

require 'rails/all'
require File.expand_path("#{ENV['RAILS_ROOT']}/config/environment.rb",  __FILE__)

puts "Testing with Rails #{Rails::VERSION::STRING} and Ruby #{RUBY_VERSION}"

require 'rspec/rails'
require 'factory_girl_rails'
require "awesome_print"
require 'vcr'
require "fakeredis"

### SETUP VCR
VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir = "#{Rails.root}/../../fixtures/vcr_cassettes"
  c.ignore_localhost = true
  c.allow_http_connections_when_no_cassette = false
end


RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = false
  config.use_transactional_fixtures = true

  def json
    JSON.parse(response.body).with_indifferent_access
  end

  def twitter_access_token
    {
      access_token: "410739240-pHPJnKJsQufXJXrH2j2gmhWx923Y4O3b1ziOZ3gi",
      access_token_secret: "B1e0enBgDm1YwQUml58WCupYHlQRjXMjtvKYjdYyT78iT"
    }
  end


  def fb_access_token
    {
      access_token: "CAAVcHuFT94wBAGvsprjaxF4EuMZB25TgpX8dn9072c2hAs3NuZC8lHr2Urdat4SAlcGnCiy4OYINxTZC7MR4JseskNZB6ehV5KDAQ95dunynDqhZBSCKm2OTh940m0OgtomsFXTtycHU3QCctKo3DXLh8oFETkwgyiYAQYUxSLlGHORqRKGiaR6aZCYWrjWXdxJKuJDBp8ZAeMd9R9ZCB1bN"
    }
  end

  def google_plus_access_token
    {
      access_token: "ya29.SQG7aQmkQ8a870DI8OoSMgA9rIrYuTCdKDdnm3leB7JMchypVE05rGOEFhWzY2glQBInLa21wQuRnw"
    }
  end

end