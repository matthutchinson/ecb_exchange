module ECB
  module Exchange
    class Convertor

      def self.find_rates(date, fetch: false)
        begin
          parsed_date = Date.parse(date)
          if parsed_date > Date.today
            raise ArgumentError.new("invalid date, it must be in the past")
          end
        end

        rates = cache.read(date)

        # if no rates found, fetch and store rates from last 90 days if requested
        # (and date asked for is within last 90 days)
        if !rates && fetch
          if (parsed_date > (Date.today - 90))
            ECB::Exchange::XMLFeed.fetch
            rates = cache.read(date)
          else
            raise ECB::Exchange::DateNotFoundError.new(date)
          end
        end

        rates
      end

      def self.convert_rates(base_rate, counter_rate)
        euro_multipler = 1.0 / base_rate
        # OK to round at 10 places, since ECB feed precision is less than this
        (counter_rate * euro_multipler).round(10)
      end

      private

      def self.cache
        @@cache ||= ECB::Exchange::Cache
      end
    end
  end
end
