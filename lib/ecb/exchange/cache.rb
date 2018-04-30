module ECB
  module Exchange
    class Cache
      KEY_PREFIX = "ecb_exchange_rates_for_date".freeze

      class << self
        attr_accessor :backend
      end

      def self.write(key, value)
        store.write(cache_key(key), value)
      end

      def self.read(key)
        store.read(cache_key(key))
      end

      # use backend if set (must respond to read, write), otherwise Rails.cache
      # will be used (if available) or we fall back to use an in-memory cache
      def self.store
        if backend
          backend
        elsif defined?(Rails) && Rails.cache
          Rails.cache
        else
          MemoryCache.cache
        end
      end

      private
        def self.cache_key(key)
          "#{KEY_PREFIX}-#{key}"
        end
    end
  end
end
