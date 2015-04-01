$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "social_login/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "social_login"
  s.version     = SocialLogin::VERSION
  s.authors     = ["William Porter"]
  s.email       = ["dawilster143@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of SocialLogin."
  s.description = "TODO: Description of SocialLogin."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.0"

  s.add_development_dependency "pg"
end
