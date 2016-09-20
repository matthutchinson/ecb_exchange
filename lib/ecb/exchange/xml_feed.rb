require "rexml/document"

module ECB
  module Exchange
    class XMLFeed

      @@endpoint = URI("http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml")

      # configurable endpoint
      def self.endpoint=(new_endpoint)
        @@endpoint = URI(new_endpoint)
      end

      def self.fetch
        begin
          url  = @@endpoint
          http = Net::HTTP.new(url.host, url.port)
          response = http.get(url.path)
          cache = ECB::Exchange::Cache.new

          if response.code == "200"
            parse(response.body) do |date, rates|
              cache.write(date, rates)
            end
            "OK"
          else
            raise ECB::Exchange::ResponseError.new(@@endpoint, "status: #{response.code}")
          end
        rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
          Errno::EHOSTUNREACH, EOFError, Errno::ECONNREFUSED, Errno::ETIMEDOUT,
          Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError,
          URI::InvalidURIError => exception
          # catch and re-raise generic error with message
          raise ECB::Exchange::ResponseError.new(@@endpoint, "#{exception} - #{exception.message}")
        end
      end

      def self.parse(xml)
        xml_doc = REXML::Document.new(xml, ignore_whitespace_nodes: :all)
        xml_doc.elements["//Cube"].each do |element|
          # date from feed is expected to be in a valid YYYY-MM-DD format
          date = Date.parse(element.attributes['time']).to_s
          # map currency rates into a hash with currency keys, rate values
          rates = element.children.map(&:attributes).inject({}) do |memo, currency_with_rate|
            memo[currency_with_rate['currency']] = currency_with_rate['rate'].to_f
            memo
          end
          # always add the base EURO rate multiplier
          rates['EUR'] = 1.0

          yield date, rates
        end
      rescue REXML::ParseException, ArgumentError
        raise ECB::Exchange::ParseError.new(@@endpoint)
      end
    end
  end
end
