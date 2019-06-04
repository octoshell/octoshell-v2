module Octoshell
  class Version
    class <<self
      RAILS_ENV=Rails.env
      VER='2.0.3'
      GIT_VER=`git describe --always`

      def ver
        tag=`git tag`.chomp
        tag=='' ? VER : tag
      end

      def full_ver
        "#{ver} (#{RAILS_ENV}) #{GIT_VER}"
      end

      def short_ver
        "#{ver} #{GIT_VER}"
      end

      def print_ver
        RAILS_ENV=='production' ? short_ver : full_ver
      end
    end
  end
end
