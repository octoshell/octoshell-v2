module Octoshell
  class Version
    class <<self
      RAILS_ENV=Rails.env
      VER='2.0.1'
      GIT_VER=`git describe --always`
      FULL_VER="#{VER} (#{RAILS_ENV}) #{GIT_VER}"
      SHORT_VER="#{VER} (#{RAILS_ENV}) #{GIT_VER}"

      def ver
        VER
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