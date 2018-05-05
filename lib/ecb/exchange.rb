require 'date'
require 'bigdecimal/util'

module ECB
  module Exchange
    VERSION = "0.1.2".freeze

    def self.convert(amount, from:, to:, date: Date.today)
      amount.to_d * rate(from: from, to: to, date: date)
    end

    def self.rate(from:, to:, date: Date.today)
      rates = XMLFeed.rates(date)

      [from, to].each do |currency|
        raise CurrencyNotFoundError.new(currency) unless rates[currency]
      end

      rates[to].to_d * 1.to_d / rates[from].to_d
    end

    def self.currencies
      XMLFeed.rates(Date.today).keys
    end
  end
end
