module Reports
  class JoinsHandler
    attr_reader :custom_join_aliases, :custom_join_strings, :inner_join, :left_join
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

    def initialize(constructor, assocation_hash, attribute_hash)
      @left_join = {}
      @inner_join = {}
      @custom_join_aliases = []
      @custom_join_strings = []

      put_assocation(assocation_hash)
      @join_dependency = ActiveRecord::Associations::JoinDependency.new(
        constructor.activerecord_class,
        @left_join,
        []
      )
      scan_all_joins
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

    def deep_copy(o)
      Marshal.load(Marshal.dump(o))
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


    def gsub(str, human, db)

      (' ' + str).gsub(/(?<=[^\.])#{human}(?=\.)/, db)
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
        yield(a) if block_given?
        # key = a.first
        # value = a.second
        # @having = gsub(@having, key, value) if @having
        # @where = gsub(@where, key, value) if @where
        @custom_join_strings = @custom_join_strings.map do |str|
                                gsub(str, key, value)
                               end
      end
    end

    def find(root, hash, path)

      return root if Array(path).empty?

      keys = hash.keys

      cur_assoc = path[0]
      index = keys.map(&:to_s).index(cur_assoc)
      raise "error" unless index
      find(root.children[index], hash[cur_assoc.to_sym], path[1..-1])
    end



  end
end
