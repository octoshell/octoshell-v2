module Jobstat
  class CacheData

  

  include Singleton

  class << self
    def get data, &block
      instance.get data, &block
    end
    def delete data
      instance.delete data
    end
  end

  def get data
    Rails.cache.fetch(data) do
      result=yield if block_given?
      if ! cache_db.transaction_open?
        cache_db.transaction do
          if result
            cache_db[data]=result
          else
            result=cache_db[data]
          end
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
    @@cache_db_singleton ||= YAML::Store.new "engines/jobstat/cache.yaml"
  end

end
end
