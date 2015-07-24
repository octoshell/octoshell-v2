require "rails/generators"
module Wiki
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def install_migrations
        puts "Copying over Wiki migrations..."
        Dir.chdir(Rails.root) do
          `rake wiki:install:migrations`
        end
      end

      def run_migrations
        puts "Running rake db:migrate"
        `rake db:migrate`
      end

      def mount_engine
        puts "Mounting Wiki::Engine at \"/wiki\" in config/routes.rb..."
        insert_into_file("#{Rails.root}/config/routes.rb", after: /routes.draw.do\n/) do
          %Q(
  # This line mounts Wiki's routes at /wiki by default.
  mount Wiki::Engine, at: "/wiki"
)
        end
      end

      def finished
        output = "\n\n" + ("*" * 53)
        output += "\nDone! Wiki engine has been successfully installed."

        puts output
      end
    end
  end
end
