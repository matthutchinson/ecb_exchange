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

        cache = ECB::Exchange::Cache
        rates = cache.read(date)

        # if no rates found, fetch and store rates from last 90 days if requested
        if !rates && fetch
          ECB::Exchange::XMLFeed.fetch
          rates = cache.read(date)
        end

        if rates
          rates
        else
          raise ECB::Exchange::DateNotFoundError.new(date)
        end
      end

      def self.convert_rates(base_rate, counter_rate)
        euro_multipler = 1.0 / base_rate
        # OK to round at 10 places, since ECB feed precision is less than this
        (counter_rate * euro_multipler).round(10)
      end
    end
  end
end
