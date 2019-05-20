module Reports
  class ConstructorService

    attr_reader :per, :page, :pages

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

    def find(root, hash, path)

      return root if Array(path).empty?

      keys = hash.keys

      cur_assoc = path[0]
      index = keys.map(&:to_s).index(cur_assoc)
      raise "error" unless index
      find(root.children[index], hash[cur_assoc.to_sym], path[1..-1])
    end

    def human_alias(hash)
      string = ''
      string << [hash[:human_prefix], hash[:column]].compact.join('.')
      string
    end

    def db_alias(hash)
      [hash[:db_prefix], hash[:column]].compact.join('_')
    end

    def db_source(hash)
      "#{hash[:db_prefix]}.#{hash[:column]}"
    end

    def put_select
      @select = []
      @attributes.each do |v|
        @select << "#{db_source(v)} AS #{db_alias(v)}"

      end

    end

    def put_order
      @order = @attributes.select do |a|
        a[:order].include?('ASC') || a[:order].include?('DESC')
      end.map do |a|
        order = a[:order]
        val = order.select { |elem| %w[ASC DESC].include?(elem) }
        raise "error" if val.count == 2
        "#{db_source(a)} #{val.first}"
      end
      @order += @complex_attributes.select do |a|
        a[2].include?('ASC') || a[2].include?('DESC')
      end.map do |a|
        order = a[2]
        val = order.select { |elem| %w[ASC DESC].include?(elem) }
        raise "error" if val.count == 2
        "#{a.second} #{val.first}"
      end
    end

    def put_group
      @group =  @attributes.select do |a|
        a[:order].include?('GROUP')
      end.map { |v| db_source(v) }
      @group += @complex_attributes.select do |a|
        a[2].include?('GROUP')
      end.map(&:second)
    end

    def deep_copy(o)
      Marshal.load(Marshal.dump(o))
    end





    def self.convert_left_to_inner(hash)
      hash.values.each do |value|
        convert_left_to_inner_assoc(value)
      end
    end

    def self.convert_left_to_inner_assoc(hash)
      res = false
      change_to_inner = false
      if hash['join_type'] == 'left'
        (hash.keys - ['join_type']).each do |key|
          change_to_inner ||= convert_left_to_inner_assoc(hash[key])
        end
      elsif hash['join_type'] == 'inner'
        res = true
      end

      if change_to_inner
        hash['join_type'] = 'inner'
        res = true
      end
      res
    end

    def split_joins(hash)
      @inner_join = {}
      @left_join = {}
      split_joins_inside(@inner_join, @left_join, hash)
    end

    def split_joins_inside(inner, left, hash)
      hash.delete('list')
      hash.each do |key, value|
        next if key == 'join_type'

        type = value['join_type']
        inner[key.to_sym] = {} if type == 'inner' && inner
        left[key.to_sym] = {}
        split_joins_inside(inner[key.to_sym], left[key.to_sym], value)
      end
    end

    def put_assocation(old_hash)
      return unless old_hash
      hash = deep_copy(old_hash)
      put_custom_joins(hash)
      self.class.convert_left_to_inner(hash)
      split_joins(hash)
    end

    def put_custom_joins(hash)
      hash.each do |key, value|
        next unless value['alias']

        hash.delete(key)
        put_custom_join(value)
      end
    end

    def put_custom_join(hash)
      @custom_join_aliases << hash['alias']
      on = hash['on']
      @custom_join_strings << "#{hash['join_type']} JOIN
      #{eval(hash['join_table']).table_name} AS #{hash['alias']} ON #{on}"
    end

    def process_attributes(hash)
      @join_dependency = ActiveRecord::Associations::JoinDependency.new(
        @activerecord_class,
        @left_join,
        []
      )
      scan_all_joins
      @complex_attributes = []
      @attributes = []
      hash.values.each do |v|
        value = v['value']
        path = value.split('.')[0..-2]
        column = value.split('.').last
        attribute = {
                      order: Array(v['order']),
                      column: column }
        if !v['label']
          @complex_attributes <<  [value, v['alias'], Array(v['order'])]
        elsif path.first == @activerecord_class.table_name
          attribute[:db_prefix] = @activerecord_class.table_name
          attribute[:human_prefix] = @activerecord_class.table_name
        elsif @custom_join_aliases.include?(path.first)
          attribute[:db_prefix] = path.first
          attribute[:human_prefix] = path.first

        else
          attribute[:db_prefix] = db_prefix_by_path(path)
          attribute[:human_prefix] = path.join('.')

        end
        @attributes << attribute if v['label']
      end

    end

    def self.delim
      %w[\s \. \( \) \, =].join('|')
    end

    def gsub(str, human, db)

      (' ' + str).gsub(/(?<=[^\.])#{human}(?=\.)/, db)
    end

    def db_prefix_by_path(path)
      table = find(@join_dependency.join_root, @left_join, path).instance_variable_get("@tables").first
      table.is_a?(Arel::Nodes::TableAlias) ? table.instance_variable_get("@right") : table.instance_variable_get("@name")
    end

    def handle_rewrite(key, value, arr)
      new_arr = arr + [key.to_s]
      @human_to_db[new_arr.join('.')] = db_prefix_by_path(new_arr)
      if value == {}
        return
      end
      value.each do |k, v|
        handle_rewrite(k, v, new_arr)
      end
    end

    def scan_all_joins
      @human_to_db = {}
      @left_join.each do |key, value|
        handle_rewrite(key, value, [])
      end
    end


    def gsub_one_string!(str)
      @human_to_db.sort_by do |key, _value|
        - key.count('.')
      end.map do |a|
        key = a.first
        value = a.second
        str = gsub(str, key, value)
      end
      str
    end

    def gsub_all!
      @human_to_db.sort_by do |key, _value|
        - key.count('.')
      end.map do |a|
        key = a.first
        value = a.second
        @having = gsub(@having, key, value) if @having
        @where = gsub(@where, key, value) if @where
        @custom_join_strings = @custom_join_strings.map do |str|
                                gsub(str, key, value)
                               end
      end
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
      @custom_join_strings = []
      @custom_join_aliases = []
      @activerecord_class = eval(hash['class_name'])
      if hash['attributes']
        @inner_join = {}
        @left_join = {}
        @alias_to_output = {}
        put_assocation(hash['association'])
        process_attributes(hash['attributes'])


        put_select
        put_order
        put_group
        @having = hash['having']
        @where = hash['where']
        gsub_all!
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
                               .joins(@inner_join).left_join(@left_join)
                               .having(@having).where(@where).select(@select)
                               .select(@complex_attributes.map { |c| [gsub_one_string!(c.first), c.second ].join(' AS ') })
      @custom_join_strings.each do |s|
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
      attribute = @attributes.detect { |a| db_alias(a) == key }
      if attribute
        human_alias(attribute)
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
