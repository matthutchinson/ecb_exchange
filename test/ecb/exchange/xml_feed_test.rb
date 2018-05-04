require File.expand_path(File.dirname(__FILE__)+'../../../test_helper')

class ECB::Exchange::XMLFeedTest < Minitest::Test
  def setup
    cache.backend = nil
    clear_cache
  end

  def test_raises_error_unless_date_is_today_or_in_the_past
    error = assert_raises(ArgumentError) do
      xml_feed.rates(Date.today + 1)
    end
    assert_equal error.message, "invalid date, must be today or in the past"
  end

  def test_raises_error_if_date_not_found
    stub_endpoint
    error = assert_raises(ECB::Exchange::DateNotFoundError) do
      xml_feed.rates(Date.today)
    end
    assert_equal error.message, "#{Date.today} is missing or unavailable"
  end

  def test_find_rates_for_a_date_from_cache
    cached_rates = { 'USD' => 1.002, 'CHF' => 1.2134 }
    cache.write(rate_date.to_s, cached_rates)
    assert_equal xml_feed.rates(rate_date), cached_rates
  end

  def test_find_rates_fetching_from_api
    stubbed_request = stub_endpoint
    rates = xml_feed.rates(rate_date)
    assert_requested stubbed_request
    assert_equal rates.values_at('USD', 'JPY', 'BGN'), %w(1.1066 113.23 1.9558)
  end

  def test_caching_rates_after_fetch_from_api
    assert_nil cache.read(rate_date.to_s)
    stub_endpoint
    xml_feed.rates(rate_date)

    assert_equal cache.read(rate_date.to_s).length, 32
    assert_equal cache.read(rate_date.to_s)['USD'], '1.1066'
  end

  def test_does_not_overwrite_cached_rates_when_fetching
    cache.write(rate_date.to_s, { 'USD' => '1337' })
    xml_feed.rates(rate_date)

    assert_equal cache.read(rate_date.to_s).length, 1
    assert_equal cache.read(rate_date.to_s)['USD'], '1337'
  end

  def test_includes_eur_rate_after_fetching
    stub_endpoint
    rates = xml_feed.rates(rate_date)

    assert_equal rates['EUR'], 1.0
    assert_equal cache.read(rate_date.to_s)['EUR'], 1.0
  end

  def test_fetching_rates_from_a_specified_endpoint
    xml_feed.endpoint = "http://awesome-currencies.io/feed.xml"
    stubbed_request = stub_endpoint(url: xml_feed.endpoint)

    rates = xml_feed.rates(rate_date)
    assert_requested stubbed_request
    assert_equal rates.length, 32

    xml_feed.endpoint = xml_feed::NINETY_DAY_ENDPOINT
  end

  def test_raises_error_with_an_unsuccessful_response
    stub_endpoint(status: 404)
    error = assert_raises(ECB::Exchange::ResponseError) do
      xml_feed.rates(rate_date)
    end

    assert_equal error.message, "fetching '#{xml_feed.endpoint}' failed - status: 404"
  end

  def test_raises_parse_error_for_invalid_feed
    stub_endpoint(response_body: xml_response("invalid_feed.xml"))
    error = assert_raises(ECB::Exchange::ParseError) do
      xml_feed.rates(rate_date)
    end

    assert_equal error.message, "parsing XML from '#{xml_feed.endpoint}' failed"
  end

  def test_raises_error_for_an_network_error
    stub_request(:get, xml_feed.endpoint).to_raise(Timeout::Error)
    error = assert_raises(ECB::Exchange::ResponseError) do
      xml_feed.rates(rate_date)
    end

    assert_equal error.message, "fetching '#{ECB::Exchange::XMLFeed.endpoint}' failed - Exception from WebMock"
  end

  private

    def xml_feed
      ECB::Exchange::XMLFeed
    end

    def stub_endpoint(url: xml_feed::NINETY_DAY_ENDPOINT, response_body: valid_xml_response, status: 200)
      stub_request(:get, url).to_return(body: response_body, status: status)
    end

    def rate_date
      Date.parse('2016-06-24')
    end
end
