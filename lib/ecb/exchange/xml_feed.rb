require "rexml/document"

module ECB
  module Exchange
    class XMLFeed

      NINETY_DAY_ENDPOINT = "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml"
      @endpoint = URI(NINETY_DAY_ENDPOINT)

      # allow a configurable endpoint
      class << self
        attr_reader :endpoint
      end

      def self.endpoint=(new_endpoint)
        @endpoint = URI(new_endpoint)
      end

      def self.fetch
        begin
          http = Net::HTTP.new(endpoint.host, endpoint.port)
          response = http.get(endpoint.path)
          cache = ECB::Exchange::Cache

          if response.code == "200"
            daily_rates = {}
            parse(response.body) do |date, rates|
              daily_rates[date] = rates
              # dont overwrite existing cached rates
              unless cache.read(date)
                cache.write(date, rates)
              end
            end

            daily_rates
          else
            raise ECB::Exchange::ResponseError.new(endpoint, "status: #{response.code}")
          end
        rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
          Errno::EHOSTUNREACH, EOFError, Errno::ECONNREFUSED, Errno::ETIMEDOUT,
          Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError,
          URI::InvalidURIError => exception
          # catch and re-raise generic error with message
          raise ECB::Exchange::ResponseError.new(endpoint, "#{exception}")
        end
      end


      private

      def self.parse(xml)
        xml_doc = REXML::Document.new(xml, ignore_whitespace_nodes: :all)
        xml_doc.elements["//Cube"].each do |element|
          # map currency rates into a hash with currency keys, rate values
          rates = element.children.map(&:attributes).inject({}) do |memo, currency_with_rate|
            memo[currency_with_rate['currency']] = currency_with_rate['rate'].to_f
            memo
          end
          # pass date and rates to block if available from feed
          if element.attributes['time'] && rates.present?
            # always add the base EURO rate multiplier
            rates['EUR'] = 1.0
            yield element.attributes['time'], rates
          end
        end
      rescue REXML::ParseException, ArgumentError
        raise ECB::Exchange::ParseError.new(endpoint)
      end
    end
  end
end
