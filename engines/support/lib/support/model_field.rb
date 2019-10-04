# ticket_field(key: 'cluster', human: :to_s, link: false,
#              query: proc { Cluster.where(available_for_work: true) })
module Support
	class ModelField
	  attr_reader :key, :query
	  def initialize(key:, query:, **args)
	    @key = key
	    @query = query
	    @human = args[:human] || :to_s
	    @link = args[:link]
	    self.class.all[key] = self
	  end
	  class << self
	    def all
	      @all ||= {}
	    end

	    def keys
	      all.keys
	    end
	  end
	end
end
