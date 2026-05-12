module Core
  module Analytics
    class Node < ApplicationRecord
      def self.versions_enabled
        pk = primary_key
        !(pk.nil? || pk.to_s.empty?)
      end
    end
  end
end