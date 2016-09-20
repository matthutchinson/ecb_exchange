class ExchangeRate

  def self.at(date, base_currency, counter_currency, fetch: false)

    rates = ECB::Exchange::Convertor.find_rates(date, fetch: fetch)

    if rates
      # check rates for currencies are present
      [base_currency, counter_currency].each do |currency|
        raise ECB::Exchange::CurrencyNotFoundError.new(currency) unless rates[currency]
      end

      ECB::Exchange::Convertor.convert_rates(
        rates[base_currency],
        rates[counter_currency]
      )
    else
      raise ECB::Exchange::DateNotFoundError.new(date)
    end
  end
end
