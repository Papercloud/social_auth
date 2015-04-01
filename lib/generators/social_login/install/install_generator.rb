require 'rails/generators/active_record'

class SocialLogin::InstallGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  source_root File.expand_path('../templates', __FILE__)

  def copy_migrations
    copy_migration "create_social_login_services"

    puts "Installation successful. You can now run:"
    puts "  rake db:migrate"
  end

  def copy_initializer
    template "initializer.rb", "config/initializers/social_login.rb"
  end

  def self.next_migration_number(dirname)
    if ActiveRecord::Base.timestamped_migrations
      Time.now.utc.strftime("%Y%m%d%H%M%S%L")
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end
  end

  private

  def copy_migration(filename)
    if self.class.migration_exists?("db/migrate", "#{filename}")
      say_status("skipped", "Migration #{filename}.rb already exists")
    else
      migration_template "#{filename}.rb", "db/migrate/#{filename}.rb"
    end
  end
end

