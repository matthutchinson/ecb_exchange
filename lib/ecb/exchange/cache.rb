module ECB
  module Exchange
    class Cache

      KEY_PREFIX = "ecb_daily_exchange_rate-"

      def self.write(key, value)
        backend.write(cache_key(key), value)
      end

      def self.read(key)
        backend.read(cache_key(key))
      end

      def self.clear
        backend.clear
      end

      # configure a backend cache object
      def self.backend=(new_backend)
        @@backend = new_backend
      end

      private

      # use Rails.cache by default if present, otherwise a cache object must be
      # set (that responds to read and write methods)
      def self.backend
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
      def self.cache_key(key)
        "#{KEY_PREFIX}#{key}"
      end
    end
  end
end
