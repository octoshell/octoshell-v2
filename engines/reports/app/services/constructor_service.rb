module Reports
  class ConstructorService

    attr_reader :per, :page, :pages, :activerecord_class, :custom_join_aliases, :joins_handler
    delegate :custom_join_aliases, :custom_join_strings, :gsub_one_string!,
    :db_prefix_by_path,:inner_join, :left_join, to: :joins_handler
    WHERE = {
      all: {
        unary: ['IS NOT NULL', 'IS NULL']
      },
      %i[boolean] => {
        unary: %w[true false]
      },
      %i[integer] => {
        binary_operators: ['>', '=', '<', '>=', '<=']
      },
      %i[datetime date time] => {
        binary_operators: ['>', '=', '<', '>=', '<=']
      },
      %i[string text] => {
        binary_operators: ['=']

      }
    }.freeze

    def self.where
      all = WHERE[:all]
      arr = WHERE.map do |key, value|
        next if key == :all
        new_value_array = value.map do |key2, value2|
          [key2, value2 + (all[key2] || [])]
        end
        new_value = all.merge Hash[new_value_array]
        [key, new_value]
      end
      Hash[arr]
    end

    def self.attributes_with_type(model)
      columns = model.columns_hash
      types = columns.map do |key, val|
        "#{key}|#{val.type}"
      end
      [columns.keys, types]
    end

    def self.class_info(array)
      cl = eval(array.first)
      array = array.drop(1)
      array.each do |elem|
        cl = cl.reflect_on_association(elem).klass
      end
      model_associations_with_type(cl) + attributes_with_type(cl)
    end

    def self.model_associations_with_type(model)
      reflections = model.reflections.values
      types = reflections.map do |r|
        type = r.macro
        "#{r.name}|#{r.class_name}|#{type}"
      end
      enums = reflections.map(&:name)
      [enums, types]
    end

    def put_select
      @select = []
      @select = @attr_array.map do |a|
        a.to_select
        # @select << "#{db_source(v)} AS #{db_alias(v)}"
      end
    end

    def put_order
      @order = @attr_array.select(&:order?).map(&:to_order)
    end

    def put_group
      @group = @attr_array.select(&:group?).map(&:to_group)
    end

    def deep_copy(o)
      Marshal.load(Marshal.dump(o))
    end

    def process_attributes(hash)

      hash.values.each do |v|
        @attr_array.add_from_hash v
      end

    end

    def self.delim
      %w[\s \. \( \) \, =].join('|')
    end

    def self.new_for_csv(hash)
      new(hash, 'csv')
    end

    def self.new_for_array(hash)
      new(hash, 'array')
    end



    def initialize(hash, type = 'csv')
      hash = deep_copy(hash)
      @type = type
      # @custom_join_strings = []
      # @custom_join_aliases = []
      @activerecord_class = eval(hash['class_name'])
      @attr_array = AttrArray.new(self)
      if hash['attributes']
        @joins_handler = JoinsHandler.new(self, hash['association'],
                                          hash['attributes'])
        process_attributes(hash['attributes'])
        put_select
        put_order
        put_group
        @having = hash['having']
        @where = hash['where']
        @joins_handler.gsub_all! do |a|
          key = a.first
          value = a.second
          @having = @joins_handler.gsub(@having, key, value) if @having
          @where = @joins_handler.gsub(@where, key, value) if @where
        end
      end

      if @type == 'array'
        @per = hash['per'].to_i
        @pages = (count.to_f / @per).ceil
        page = (hash['page'] || 1).to_i
        @page = page > @pages ? @pages : page
      end
    end


    def count
      base_relation.select('count(*) OVER() AS count_all')
                   .to_a.first.attributes['count_all'].to_i
    end

    def base_relation
      rel = @activerecord_class.order(@order).group(@group)
                               .joins(inner_join).left_outer_joins(left_join)
                               .having(@having).where(@where).select(@select)
      custom_join_strings.each do |s|
        rel = rel.joins(s)
      end
      rel
    end

    def form_relation
      if @type == 'array'
        base_relation.page(@page).per(@per)
      else
        base_relation
      end
    end

    def to_sql
      form_relation.to_sql
    end

    def to_2d_array
      a = to_a
      [head(a.first)] + lightweight_to_a
    end

    def find_human_alias(key)
      attribute = @attr_array.detect { |a| !a.complex? && a.db_alias == key }
      if attribute
        attribute.human_alias
      else
        key
      end
    end

    def head(row)
      return unless row

      row.keys
    end

    def lightweight_to_a
      ActiveRecord::Base.connection.execute(form_relation.to_sql).map do |a|
        a.values
      end
    end

    def to_a
      ActiveRecord::Base.connection.execute(form_relation.to_sql).map do |a|
        Hash[a.map do |key, value|
          [find_human_alias(key), value]
        end]
      end
    end

    def to_csv
      CSV.generate do |csv|
        to_2d_array.each do |row|
          csv << row
        end
      end
    end
  end
end
