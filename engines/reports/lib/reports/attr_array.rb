module Reports
  class AttrArray
    attr_reader :attributes
		delegate :each, :select, :detect, :map, to: :attributes 
    def initialize(constructor)
      @attributes = []
			@constructor = constructor
    end

    def add_from_hash(hash)
      attributes << Attribute.new(@constructor, hash)
    end
  end
end
