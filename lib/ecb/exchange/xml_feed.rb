require "rexml/document"
require "net/http"
require "uri"

module ECB
  module Exchange
    class XMLFeed

      NINETY_DAY_ENDPOINT = "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml".freeze
      @endpoint = URI(NINETY_DAY_ENDPOINT)

      # allow a configurable endpoint
      class << self
        attr_reader :endpoint
      end

      def self.endpoint=(new_endpoint)
        @endpoint = URI(new_endpoint)
      end

      def self.rates(date)
        if date > Date.today
          raise ArgumentError.new("invalid date, must be today or in the past")
        end

        # find rates in cache, or fetch (and cache)
        date  = date.to_s
        rates = Cache.read(date) || fetch_and_cache[date]
        rates ? rates : raise(DateNotFoundError.new(date))
      end

      private

        def self.fetch_and_cache
          daily_rates = {}
          parse(get_xml) do |date, rates|
            daily_rates[date] = rates
            # dont overwrite existing cached rates
            Cache.write(date, rates) unless Cache.read(date)
          end
          daily_rates
        end

        def self.get_xml
          resp = Net::HTTP.new(endpoint.host, endpoint.port).get(endpoint.path)
          if resp.code == "200"
            resp.body
          else
            raise ResponseError.new(endpoint, "status: #{resp.code}")
          end
        rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
          Errno::EHOSTUNREACH, EOFError, Errno::ECONNREFUSED, Errno::ETIMEDOUT,
          Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError,
          URI::InvalidURIError => exception
          # catch and re-raise generic error with message
          raise ResponseError.new(endpoint, exception.to_s)
        end

        def self.parse(xml)
          elements = rate_elements(xml)
          raise ParseError.new(endpoint) unless elements

          elements.each do |element|
            # map currency rates into a hash with currency keys, rate values
            # and always add the base EUR rate multiplier
            rates = parse_element(element).merge('EUR' => 1.0)

            # pass date and rates to block
            yield element.attributes['time'], rates
          end
        rescue REXML::ParseException, ArgumentError
          raise ParseError.new(endpoint)
        end

        def self.rate_elements(xml)
          REXML::Document.new(xml, ignore_whitespace_nodes: :all).elements["//Cube"]
        end

        def self.parse_element(element)
          element.children.map(&:attributes).inject({}) do |memo, currency_with_rate|
            memo[currency_with_rate['currency']] = currency_with_rate['rate'].to_f
            memo
          end
        end
    end
  end
end
