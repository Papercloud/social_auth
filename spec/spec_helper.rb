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
  c.cassette_library_dir = "#{Rails.root}/../../spec/fixtures/vcr_cassettes"
  c.ignore_localhost = true
  c.allow_http_connections_when_no_cassette = false
end


RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = false
  config.use_transactional_fixtures = true

  def json
    JSON.parse(response.body).with_indifferent_access
  end

  def fb_access_token
    {access_token: "CAAVcHuFT94wBAA509NYoqiKeT5wHhj1rCEYYpOHlAvCy4gyc6UpaWpBdHuZAjT835eAVtbf4aJcv052CQQTT3qGmuDEiH2D5OUMxvIzIT5nfwDhJioJo8FnwaBicYXuTEiFZCJPyeWm81BjPkwgbM9HvPA1xj9GIThbd6EBmK88jvs6iMfYCi9n5CuTV959V23RXkdZB8weXZA7YHuQ6"}
  end

end