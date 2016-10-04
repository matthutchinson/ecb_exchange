require File.expand_path(File.dirname(__FILE__)+'../../../test_helper')

describe ECB::Exchange::XMLFeed do

  describe 'fetching XML' do

    describe 'with a valid response' do

      before(:each) do
        cache.clear
        stub_request(:get, ECB::Exchange::XMLFeed.endpoint).to_return(
          body: response_fixture('eurofxref-hist-90d.xml')
        )
      end

      it 'should fetch and parse successfully' do
        rates = ECB::Exchange::XMLFeed.fetch

        assert_equal rates.length, 64
        assert_equal rates['2016-06-24'].length, 32
        assert_equal rates['2016-06-24'].values_at('USD', 'JPY', 'BGN'),
                     [1.1066, 113.23, 1.9558]
      end

      it 'should cache rates from feed' do
        assert_equal cache.read('2016-06-24'), nil

        ECB::Exchange::XMLFeed.fetch
        assert_equal cache.read('2016-06-24').length, 32
        assert_equal cache.read('2016-06-24')['USD'], 1.1066
      end

      it 'should not overwrite existing cached rates for a given date' do
        cache.write('2016-06-24', { 'USD' => 1337 })

        ECB::Exchange::XMLFeed.fetch
        assert_equal cache.read('2016-06-24').length, 1
        assert_equal cache.read('2016-06-24')['USD'], 1337
      end

      it 'should include the base EUR (1) multiplier rate' do
        rates = ECB::Exchange::XMLFeed.fetch
        assert_equal rates['2016-06-24'].values_at('USD', 'EUR'), [1.1066, 1.0]
      end

      describe 'from an alternative URL endpoint' do

        before do
          ECB::Exchange::XMLFeed.endpoint = "http://awesome-currencies.io/feed.xml"
        end

        after do
          ECB::Exchange::XMLFeed.endpoint = ECB::Exchange::XMLFeed::NINETY_DAY_ENDPOINT
        end

        it 'should fetch and parse xml feed successfully' do
          stubbed_request = stub_request(:get, ECB::Exchange::XMLFeed.endpoint).to_return(
            body: response_fixture('eurofxref-hist-90d.xml')
          )

          rates = ECB::Exchange::XMLFeed.fetch
          assert_requested stubbed_request
          assert_equal rates.length, 64
        end
      end
    end


    describe 'with an invalid response' do

      it 'should raise an error when response code is unsuccessful' do
        stub_request(:get, ECB::Exchange::XMLFeed.endpoint).to_return(
          body: "", status: 404
        )
        exception = assert_raises(ECB::Exchange::ResponseError) do
          ECB::Exchange::XMLFeed.fetch
        end

        assert_equal exception.message, "fetching '#{ECB::Exchange::XMLFeed.endpoint}' failed - status: 404"
      end

      it 'should raise an error when a network error occurs' do
        stub_request(:get, ECB::Exchange::XMLFeed.endpoint).to_raise(Timeout::Error)
        exception = assert_raises(ECB::Exchange::ResponseError) do
          ECB::Exchange::XMLFeed.fetch
        end

        assert_equal exception.message, "fetching '#{ECB::Exchange::XMLFeed.endpoint}' failed - Exception from WebMock"
      end

      it 'should raise an error if XML parsing fails' do
        stub_request(:get, ECB::Exchange::XMLFeed.endpoint).to_return(
          body: response_fixture('invalid_feed.xml')
        )

        exception = assert_raises(ECB::Exchange::ParseError) do
          ECB::Exchange::XMLFeed.fetch
        end

        assert_equal exception.message, "parsing XML from '#{ECB::Exchange::XMLFeed.endpoint}' failed"
      end
    end
  end
end
