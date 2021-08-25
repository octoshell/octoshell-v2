module Jobstat
  class CacheData

  @@in_transaction = false

  include Singleton

  class << self
    def get data, &block
      instance.get data, &block
    end
    def delete data
      instance.delete data
    end
  end

  def do_transaction &block
    if @@in_transaction
      yield block
    else
      @@in_transaction = true
      cache_db.transaction do
        yield block
      end
      @@in_transaction = false
    end
  end

  def get data
    Rails.cache.fetch(data) do
      result=yield if block_given?
      do_transaction do
        if result
          cache_db[data]=result
        else
          result=cache_db[data]
        end
      end
      result
    end
  end

  def delete data
    Rails.cache.delete data
    cache_db.transaction do
      cache_db.delete data
    end
  end

private
  def cache_db
    # FIXME! change path...
    #@@cache_db_singleton ||= YAML::Store.new(Rails.root + '/engines/jobstat/cache.yaml')
    @@cache_db_singleton ||= YAML::Store.new(File.expand_path('../../cache.yaml', __FILE__))
  end

end
end
