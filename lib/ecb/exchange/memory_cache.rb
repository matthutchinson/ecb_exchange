module ECB
  module Exchange
    class MemoryCache
      def self.cache
        @cache ||= new
      end

      def initialize
        @store = {}
      end

      def read(key)
        @store[key]
      end

      def write(key, value)
        @store[key] = value
      end

      def clear
        @store.clear
      end
    end
  end
end
