$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "social_auth/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "social_auth"
  s.version     = SocialAuth::VERSION
  s.authors     = ["William Porter"]
  s.email       = ["wp@papercloud.com.au"]
  s.homepage    = "http://papercloud.com"
  s.summary     = "Tool for connecting multiple social networks to user's account"
  s.description = ""
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'rails', '~> 4.0'
  s.add_dependency 'fb_graph2'
  s.add_dependency 'twitter'
  s.add_dependency 'google_plus', '~> 0.2.3'
  s.add_dependency 'sidekiq'
  s.add_dependency 'typhoeus'

  s.add_development_dependency 'fakeredis'
  s.add_development_dependency "pg"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'webmock'

end
