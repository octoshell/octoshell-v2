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
      build_join_dependency(constructor.activerecord_class)
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
      hash.keys.each do |key|
        value = hash[key]
        next unless value.is_a?(Hash) && value['alias']

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

    def build_join_dependency(activerecord_class)
      @join_dependency = ActiveRecord::Associations::JoinDependency.new(
        activerecord_class,
        activerecord_class.arel_table,
        @left_join,
        Arel::Nodes::OuterJoin
      )
      @alias_tracker = ActiveRecord::Associations::AliasTracker.create(
        activerecord_class.connection_pool,
        activerecord_class.table_name,
        []
      )
      @join_dependency.join_constraints([], @alias_tracker, [])
    end

    def db_prefix_by_path(path)
      human_path = Array(path).join('.')
      @human_to_db.fetch(human_path) do
        raise ArgumentError, "Can't resolve a table for '#{human_path}': association is not joined"
      end
    end

    def scan_all_joins
      @human_to_db = {}
      walk_join_root(@join_dependency.send(:join_root), [])
    end

    def walk_join_root(node, path)
      node.children.each do |child|
        child_path = path + [child.reflection.name.to_s]
        @human_to_db[child_path.join('.')] = child.table.name
        walk_join_root(child, child_path)
      end
    end


    def gsub(str, human, db)
      (' ' + str).gsub(/(?<=[^\.])#{Regexp.escape(human)}(?=\.)/, db)
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
      end.each do |key, value|
        yield([key, value]) if block_given?
        @custom_join_strings = @custom_join_strings.map do |str|
          gsub(str, key, value)
        end
      end
    end

  end
end
