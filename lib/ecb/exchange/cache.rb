module ECB
  module Exchange
    class Cache

      KEY_PREFIX = "ecb_daily_exchange_rate-"

      # allow a configurable backend cache object
      class << self
        attr_accessor :backend
      end

      def self.write(key, value)
        store.write(cache_key(key), value)
      end

      def self.read(key)
        store.read(cache_key(key))
      end

      def self.clear
        store.clear
      end

      private

      # use Rails.cache by default if present, otherwise a cache object must be
      # set (that responds to read, write, clear methods)
      def self.store
        if backend
          backend
        elsif defined?(Rails) && Rails.cache
          Rails.cache
        else
          raise ECB::Exchange::CacheBackendError
        end
      end

      # since this cache may be shared with other objects
      # a prefix is used in all cache keys
      def self.cache_key(key)
        "#{KEY_PREFIX}#{key}"
      end
    end
  end
end
