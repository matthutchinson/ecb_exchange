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
        rates = Cache.read(date) || fetch[date]
        rates ? rates : raise(DateNotFoundError.new(date))
      end

      private

        def self.fetch
          begin
            http = Net::HTTP.new(endpoint.host, endpoint.port)
            response = http.get(endpoint.path)
            daily_rates = {}

            if response.code == "200"
              parse(response.body) do |date, rates|
                daily_rates[date] = rates
                # dont overwrite existing cached rates
                unless Cache.read(date)
                  Cache.write(date, rates)
                end
              end

              daily_rates
            else
              raise ResponseError.new(endpoint, "status: #{response.code}")
            end
          rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
            Errno::EHOSTUNREACH, EOFError, Errno::ECONNREFUSED, Errno::ETIMEDOUT,
            Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError,
            URI::InvalidURIError => exception
            # catch and re-raise generic error with message
            raise ResponseError.new(endpoint, exception.to_s)
          end
        end

        def self.parse(xml)
          xml_doc = REXML::Document.new(xml, ignore_whitespace_nodes: :all)
          xml_doc.elements["//Cube"].each do |element|
            # map currency rates into a hash with currency keys, rate values
            rates = element.children.map(&:attributes).inject({}) do |memo, currency_with_rate|
              memo[currency_with_rate['currency']] = currency_with_rate['rate'].to_f
              memo
            end

            # pass date and rates to block if available from feed
            if element.attributes['time'] && !rates.empty?
              # always add the base EURO rate multiplier
              rates['EUR'] = 1.0
              yield element.attributes['time'], rates
            end
          end
        rescue REXML::ParseException, ArgumentError
          raise ParseError.new(endpoint)
        end
    end
  end
end
