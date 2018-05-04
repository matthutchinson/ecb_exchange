require File.expand_path(File.dirname(__FILE__) + "../../test_helper")

class ECB::ExchangeTest < Minitest::Test
  def setup
    stub_request(:get, ECB::Exchange::XMLFeed.endpoint).to_return(
      body: valid_xml_response
    )
  end

  def test_convert_for_todays_rate
    with_today_as("2016-09-19") do
      assert_equal ECB::Exchange.convert(100, from: 'USD', to: 'GBP').round(2), 76.58
    end
  end

  def test_convert_for_date_in_past
    date = Date.parse("2016-08-04")
    assert_equal ECB::Exchange.convert(100, from: 'USD', to: 'GBP', date: date).round(2), 75.97
  end

  def test_rate_for_today
    with_today_as("2016-09-19") do
      assert_equal ECB::Exchange.rate(from: 'USD', to: 'GBP').round(4), 0.7658
    end
  end

  def test_rate_for_date_in_past
    date = Date.parse("2016-08-04")
    assert_equal ECB::Exchange.rate(from: 'USD', to: 'GBP', date: date).round(4), 0.7597
  end

  def test_convert_returns_big_decimal
    with_today_as("2016-09-19") do
      assert_kind_of BigDecimal, ECB::Exchange.convert(100, from: 'USD', to: 'GBP')
    end
  end

  def test_rate_returns_big_decimal
    with_today_as("2016-09-19") do
      assert_kind_of BigDecimal, ECB::Exchange.rate(from: 'USD', to: 'GBP')
    end
  end

  def test_rate_for_date_not_present
    date = Date.parse("2011-08-04")
    error = assert_raises(ECB::Exchange::DateNotFoundError) do
      ECB::Exchange.rate(from: 'USD', to: 'GBP', date: date)
    end

    assert_equal error.message, "#{date} is missing or unavailable"
  end

  def test_rate_for_currency_not_present
    date = Date.parse("2016-08-04")
    error = assert_raises(ECB::Exchange::CurrencyNotFoundError) do
      ECB::Exchange.rate(from: 'XXY', to: 'GBP', date: date)
    end

    assert_equal error.message, "XXY is missing or unavailable"
  end

  def test_currencies
    with_today_as("2016-09-19") do
      assert_equal ECB::Exchange.currencies, %w(
        USD JPY BGN CZK DKK GBP HUF PLN RON SEK CHF NOK HRK RUB TRY AUD BRL CAD
        CNY HKD IDR ILS INR KRW MXN MYR NZD PHP SGD THB ZAR EUR
      )
    end
  end
end
