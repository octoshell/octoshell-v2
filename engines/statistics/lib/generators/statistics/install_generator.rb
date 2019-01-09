require "rails/generators"
module Statistics
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def install_migrations
        puts "Copying over Statistics migrations..."
        Dir.chdir(Rails.root) do
          `rake statistics:install:migrations`
        end
      end

      def run_migrations
        puts "Running rake db:migrate"
        `rake db:migrate`
      end

      def mount_engine
        puts "Mounting Statistics::Engine at \"/statistics\" in config/routes.rb..."
        insert_into_file("#{Rails.root}/config/routes.rb", after: /routes.draw.do\n/) do
          %Q(
  # This line mounts Statistics routes at /admin/stats by default.
  mount Statistics::Engine, :at => "/admin/stats"
)
        end
      end

      def finished
        output = "\n\n" + ("*" * 53)
        output += "\nDone! Statistics engine has been successfully installed."

        puts output
      end
    end
  end
end
