module ECB
  module Exchange
    class Error < StandardError; end

    class DateNotFoundError < Error
      def initialize(date)
        super("#{date} is missing or unavailable")
      end
    end

    class CurrencyNotFoundError < Error
      def initialize(currency_code)
        super("#{currency_code} is missing or unavailable")
      end
    end

    class ResponseError < Error
      def initialize(url, error_details)
        super("fetching '#{url}' failed - #{error_details}")
      end
    end

    class ParseError < Error
      def initialize(url)
        super("parsing XML from '#{url}' failed")
      end
    end
  end
end
