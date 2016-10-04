require 'test_helper'

describe ExchangeRate do

  before do
    cache.clear
  end

  describe 'with cached rates' do

    before do
      cache.write('2016-01-01', { 'USD' => 0.87217, 'CHF' => 0.9912134 })
    end

    it 'should return exchange rate for a given day' do
      assert_equal ExchangeRate.at('2016-01-01', 'USD', 'CHF'), 1.1364910511
    end

    it 'should raise an error if currency not found' do
      exception = assert_raises(ECB::Exchange::CurrencyNotFoundError) do
        ExchangeRate.at('2016-01-01', 'USD', 'XXY')
      end

      assert_equal exception.message, "XXY is missing or unavailable"
    end

    it 'should raise an error if date not found' do
      exception = assert_raises(ECB::Exchange::DateNotFoundError) do
        ExchangeRate.at(Date.today.to_s, 'USD', 'CHF')
      end

      assert_equal exception.message, "#{Date.today} is missing or unavailable"
    end
  end

  describe 'fetching rates' do
    it 'should fetch, cache and return exchange rate for a given day' do
      stubbed_request = stub_request(:get, ECB::Exchange::XMLFeed.endpoint).to_return(
        body: response_fixture('eurofxref-hist-90d.xml')
      )

      multiplier = ExchangeRate.at('2016-06-24', 'USD', 'JPY', fetch: true)
      assert_requested stubbed_request
      assert_equal multiplier, 102.322429062
    end
  end
end
