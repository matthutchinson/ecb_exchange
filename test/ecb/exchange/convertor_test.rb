require File.expand_path(File.dirname(__FILE__)+'../../../test_helper')

describe ECB::Exchange::Convertor do

  describe 'finding rates' do

    before do
      cache.clear
    end

    it 'should find rates from the cache' do
      cached_rates = { 'USD' => 1.002, 'CHF' => 1.2134 }
      cache.write('2016-01-01', cached_rates)

      assert_equal ECB::Exchange::Convertor.find_rates('2016-01-01'), cached_rates
    end

    it 'should require that date be today or in the past' do
      exception = assert_raises(ArgumentError) do
        ECB::Exchange::Convertor.find_rates('3199-01-01')
      end

      assert_equal exception.message, "invalid date, it must be in the past"
    end

    describe 'cache is empty' do

      it 'should raise an error if date cannot be found' do
        exception = assert_raises(ECB::Exchange::DateNotFoundError) do
          ECB::Exchange::Convertor.find_rates(Date.today.to_s)
        end

        assert_equal exception.message, "#{Date.today} is missing or unavailable"
      end

      it 'should fetch from feed and return rates for day' do
        stubbed_request = stub_request(:get, ECB::Exchange::XMLFeed.endpoint).to_return(
          body: response_fixture('eurofxref-hist-90d.xml')
        )
        rates = ECB::Exchange::Convertor.find_rates('2016-06-24')
        assert_requested stubbed_request
        assert_equal rates.values_at('USD', 'JPY', 'BGN'), [1.1066, 113.23, 1.9558]
      end
    end
  end

  describe 'converting rates' do

    it 'should convert rates for a given day, returning multipler' do
      assert_equal ECB::Exchange::Convertor.convert_rates(1.45, 1.0034), 0.692
    end
  end
end
