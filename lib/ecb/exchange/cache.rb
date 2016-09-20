module ECB
  module Exchange
    class Cache

      KEY_PREFIX = "ecb_daily_exchange_rate-"

      def write(key, value)
        backend.write(cache_key(key), value)
      end

      def read(key)
        backend.read(cache_key(key))
      end

      # configure a backend cache object
      def self.backend=(new_backend)
        @@backend = new_backend
      end

      private

      # use Rails.cache by default if present, otherwise a cache object must be
      # set (that responds to read and write methods)
      def backend
        @@backend ||= begin
          if defined?(Rails) && Rails.cache
            Rails.cache
          else
            raise ECB::Exchange::CacheBackendError
          end
        end
      end

      # since this cache may be shared with other objects
      # a prefix is used in all cache keys
      def cache_key(key)
        "#{KEY_PREFIX}#{key}"
      end
    end
  end
end
