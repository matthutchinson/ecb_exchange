require 'date'

module ECB
  module Exchange
    VERSION = "0.1.0".freeze

    def self.convert(amount, from:, to:, date: Date.today)
      amount * rate(from: from, to: to, date: date)
    end

    def self.rate(from:, to:, date: Date.today)
      rates = XMLFeed.rates(date)

      [from, to].each do |currency|
        raise CurrencyNotFoundError.new(currency) unless rates[currency]
      end

      rates[to] * (1.0 / rates[from])
    end

    def self.currencies
      XMLFeed.rates(Date.today).keys
    end
  end
end
