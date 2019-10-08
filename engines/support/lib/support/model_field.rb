# ticket_field(key: 'cluster', human: :to_s, link: false,
#              query: proc { Cluster.where(available_for_work: true) })
module Support
  class ModelField
    attr_reader :key, :admin_query, :user_query, :human, :admin_link, :user_link,
                :admin_source, :user_source
    def initialize(key:, **args)
      @key = key
      @admin_query = args[:admin_query] || args [:user_query]
      @user_query = args[:user_query] || args [:admin_query]
      unless @admin_query || @user_query
        raise 'You should pass :admin_query or :user_query'
      end
      @admin_link = args[:admin_link]
      @user_link = args[:user_link]
      @admin_source = args[:admin_source]
      @user_source = args[:user_source]

      @human = args[:human] || :to_s
      self.class.all[key] = self
    end

    def model
      @model ||= admin_query.call(User.first).model
    end

    def type_source(condition)
      send(condition ? :admin_source : :user_source)
    end

    def type_query(condition)
      send(condition ? :admin_query : :user_query)
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
