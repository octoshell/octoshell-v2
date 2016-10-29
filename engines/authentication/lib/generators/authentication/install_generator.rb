require "rails/generators"
module Authentication
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def install_migrations
        puts "Copying over Authentication migrations..."
        Dir.chdir(Rails.root) do
          `rake authentication:install:migrations`
        end
      end

      def run_migrations
        puts "Running rake db:migrate"
        `rake db:migrate`
      end

      def mount_engine
        puts "Mounting Authentication::Engine at \"/auth\" in config/routes.rb..."
        insert_into_file("#{Rails.root}/config/routes.rb", after: /routes.draw.do\n/) do
          %Q(
  # This line mounts Authentication's routes at /auth by default.
  mount Authentication::Engine, at: "/auth"
)
        end
      end

      def finished
        output = "\n\n" + ("*" * 53)
        output += "\nDone! Authentication engine has been successfully installed."

        puts output
      end
    end
  end
end
