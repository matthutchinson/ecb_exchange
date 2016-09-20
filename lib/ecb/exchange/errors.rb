module ECB
  module Exchange

    class DateNotFoundError < StandardError
      def initialize(date)
        super("#{date} is missing or unavailable")
      end
    end

    class CurrencyNotFoundError < StandardError
      def initialize(currency_code)
        super("#{currency_code} is missing or unavailable")
      end
    end


    class ResponseError < StandardError
      def initialize(url, error_details)
        super("fetching '#{url}' failed - #{error_details}")
      end
    end

    class ParseError < StandardError
      def initialize(url)
        super("parsing XML from '#{url}' failed")
      end
    end

    class CacheBackendError < StandardError
      def initialize
        super("No backend set for caching rates, set one with `ECB::Exchange::Cache.backend =`")
      end
    end
  end
end
