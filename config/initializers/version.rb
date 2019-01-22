module Octoshell
  class Version
    class <<self
      RAILS_ENV=Rails.env
      VER='2.0.1'
      GIT_VER=`git describe --always`
      FULL_VER="#{ver} (#{RAILS_ENV}) #{GIT_VER}"
      SHORT_VER="#{ver} (#{GIT_VER})"

      def ver
        tag=`git tag`.chomp
        tag=='' ? VER : tag
      end

      def full_ver
        FULL_VER
      end

      def print_ver
        RAILS_ENV=='production' ? SHORT_VER : FULL_VER
      end
    end
  end
end
