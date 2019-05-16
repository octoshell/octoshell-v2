module Reports
  class AssocsGraph
    def initialize(key, value, join_dependency)
      @children = []
			@join_dependency = join_dependency
			unless key
				# join_dependency.
			end
      hash.each do |key, value|
        next unless value.nil? || value != {}

        @children << AssocsGraph.new(key, value, join_dependency)
      end
    end

		def find_by_key
			
		end
  end
end
