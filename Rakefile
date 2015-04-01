require "bundler"
require 'rake'
Bundler.setup
Bundler::GemHelper.install_tasks

def cmd(command)
  puts command
  raise unless system command
end

# Import all our rake tasks
FileList['tasks/**/*.rake'].each { |task| import task }

# begin
#   require 'bundler/setup'
# rescue LoadError
#   puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
# end

# require 'rdoc/task'

# RDoc::Task.new(:rdoc) do |rdoc|
#   rdoc.rdoc_dir = 'rdoc'
#   rdoc.title    = 'SocialLogin'
#   rdoc.options << '--line-numbers'
#   rdoc.rdoc_files.include('README.rdoc')
#   rdoc.rdoc_files.include('lib/**/*.rb')
# end

# APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
# load 'rails/tasks/engine.rake'


# load 'rails/tasks/statistics.rake'



# Bundler::GemHelper.install_tasks

