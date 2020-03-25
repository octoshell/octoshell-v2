module Reports
  class Attribute
    attr_reader :order, :column, :constructor
    delegate :activerecord_class, :custom_join_aliases,
    :db_prefix_by_path, :gsub_one_string!, to: :constructor

    def improved_inspect
      "#{@column}\ndb_source=#{db_source}\ndb_alias=#{db_alias}\nhuman=#{human_alias}\n------"
    end

    def complex?
      !@column
    end

    def db_alias
      [@aggregate&.downcase, @db_prefix, @column].compact.join('_')
    end

    def db_source
      return @alias if complex?
      if @aggregate
        return "#{@aggregate}(#{@db_prefix}.#{@column})"

      end

      "#{@db_prefix}.#{@column}"
    end

    def human_alias
      if @aggregate
        "#{@aggregate&.downcase}_#{[@human_prefix, @column].compact.join('.')}"
      else
        [@human_prefix, @column].compact.join('.')
      end
    end


    def to_select
      if complex?
        [gsub_one_string!(@value), @alias].join(' AS ')
      else
        "#{db_source} AS #{db_alias}"
      end
    end

    def order?
      @order.include?('ASC') || @order.include?('DESC')
    end

    def group?
      @order.include?('GROUP')
    end

    def to_order
      # order = a[:order]
      val = order.select { |elem| %w[ASC DESC].include?(elem) }
      raise "error" if val.count == 2

      if complex?
        # [gsub_one_string!(@value), @alias].join(' AS ')
        "#{@alias} #{val.first}"

      else
        "#{db_source} #{val.first}"
        # order = a[:order]
      end
    end

    def to_group
      db_source
    end



    def initialize(constructor, hash)
      @constructor = constructor
      @value = hash['value']
      @aggregate = hash['aggregate']
      path = @value.split('.')[0..-2]
      if hash['label']
        @column = @value.split('.').last
      else
        @alias = hash['alias']
      end
      @order = Array(hash['order'])
      if !hash['label']

        # @complex_attributes << [value, v['alias'], Array(v['order'])]
      elsif path.first == activerecord_class.table_name
        @db_prefix = activerecord_class.table_name
        @human_prefix = activerecord_class.table_name
      elsif custom_join_aliases.include?(path.first)
        @db_prefix = path.first
        @human_prefix = path.first
      else
        @db_prefix = db_prefix_by_path(path)
        @human_prefix = path.join('.')
      end
      # @attributes << attribute if v['label']
    end
  end
end
