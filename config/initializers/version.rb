module Octoshell
  class Version
    class <<self
      RAILS_ENV = Rails.env
      VER = '2.8.0'
      GIT_VER = `git describe --tags --long`.chomp

      def ver
        tag = GIT_VER
        tag=='' ? VER : tag
      end

      def full_ver
        "#{ver} (#{RAILS_ENV})"
      end

      def short_ver
        ver
      end

      def print_ver
        RAILS_ENV=='production' ? short_ver : full_ver
      end
    end
  end
end
