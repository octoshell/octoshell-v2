require "rails/generators"
module Face
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def mount_engine
        puts "Mounting Face::Engine at \"/\" in config/routes.rb..."
        insert_into_file("#{Rails.root}/config/routes.rb", after: /routes.draw.do\n/) do
          %Q(
  # This line mounts Face's routes at / by default.
  mount Face::Engine, at: "/"
)
        end
      end

      def finished
        output = "\n\n" + ("*" * 53)
        output += "\nDone! Face engine has been successfully installed."

        puts output
      end
    end
  end
end
