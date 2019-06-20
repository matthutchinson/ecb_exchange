# ECB Exchange

[![Gem](https://img.shields.io/gem/v/ecb_exchange.svg?style=flat)](http://rubygems.org/gems/ecb_exchange)
[![Travis](https://img.shields.io/travis/com/matthutchinson/ecb_exchange/master.svg?style=flat)](https://travis-ci.com/matthutchinson/ecb_exchange)
[![Depfu](https://img.shields.io/depfu/matthutchinson/ecb_exchange.svg?style=flat)](https://depfu.com/github/matthutchinson/ecb_exchange)
[![Maintainability](https://api.codeclimate.com/v1/badges/c67969dd7b921477bdcc/maintainability)](https://codeclimate.com/github/matthutchinson/ecb_exchange/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/c67969dd7b921477bdcc/test_coverage)](https://codeclimate.com/github/matthutchinson/ecb_exchange/test_coverage)

Currency conversion using the European Central Bank's foreign [exchange
rates](https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml). Rates
for the last 90 days are fetched and cached on demand. All calculations are
  performed and returned as `BigDecimal` (usually a [good
  idea](https://makandracards.com/makandra/1178-bigdecimal-arithmetic-in-ruby)
  when dealing with money).

## Requirements

* [Ruby](http://ruby-lang.org/) >= 2.3

## Installation

Add this line to your Gemfile and run `bundle install`:

```ruby
gem 'ecb_exchange'
```

## Usage

Convert an amount from one currency to another:

```ruby
ECB::Exchange.convert(100, from: 'EUR', to: 'GBP')
=> 0.88235e2
```

The converted amount (using today's current rate) will be returned as
`BigDecimal`. In doing this, the gem will fetch and cache ECB rates for the last
90 days.

Convert an amount on a specific date:

```ruby
ECB::Exchange.convert(100, from: 'EUR', to: 'GBP', date: Date.parse('2017-01-11'))
=> 0.87235e2
```

To fetch the exchange rate multiplier between two currencies:

```ruby
ECB::Exchange.rate(from: 'EUR', to: 'USD') # pass an optional `date` arg here too
=> 0.11969e1
```

You can ask for an array of all supported currencies with:

```ruby
ECB::Exchange.currencies
=> ["USD", "JPY", "BGN", "CZK", "DKK", "GBP", "HUF" ... ]
```

Finally, you can adjust the rates endpoint by setting your own
`XMLFeed.endpoint` (e.g. in an initializer):

```ruby
ECB::Exchange::XMLFeed.endpoint = "http://my-awesome-service.com/feed.xml"
```

The XML feed at this endpoint must conform to the [ECB
rates](https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml)
structure.

## Handling Errors

Not all dates, rates or currencies may be available, or the remote endpoint
could be unresponsive. For these cases consider handling these errors:

* `ECB::Exchange::DateNotFoundError`
* `ECB::Exchange::CurrencyNotFoundError`
* `ECB::Exchange::ResponseError`
* `ECB::Exchange::ParseError`

Or rescue `ECB::Exchange::Error` to catch any of them.

## Caching

By default rates will be cached to one of the following backend stores (in this
order of preference).

* Your own backend cache store (see below)
* `Rails.cache`
* An `ECB::Exchange::MemoryCache` instance (a simple in memory cache store)

To configure your own backend store (e.g. in an initializer):

```ruby
ECB::Exchange::Cache.backend =  MyAwesomeCache.new
# this cache must implement public `read(key)` and `write(key, value)` methods
```

All keys in the cache are name-spaced with a `ecb_exchange_rates_for_date-`
prefix.

## Development

Check out this repo and run `bin/setup`, this will install gem dependencies and
generate docs. Use `bundle exec rake` to run tests and generate a coverage
report.

You can also run `bin/console` for an interactive prompt to experiment with the
code.

## Tests

MiniTest is used for testing. Run the test suite with:

    $ rake test

## Docs

Generate docs for this gem with:

    $ rake rdoc

## Troubles?

If you think something is broken or missing, please raise a new
[issue](https://github.com/matthutchinson/ecb_exchange/issues). Please remember
to check it hasn't already been raised.

## Contributing

Bug [reports](https://github.com/matthutchinson/ecb_exchange/issues) and [pull
requests](https://github.com/matthutchinson/ecb_exchange/pulls) are welcome on
GitHub. When submitting pull requests, remember to add tests covering any new
behaviour, and ensure all tests are passing on
[Travis](https://travis-ci.com/matthutchinson/ecb_exchange). Read the
[contributing
guidelines](https://github.com/matthutchinson/ecb_exchange/blob/master/CONTRIBUTING.md)
for more details.

This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the [Contributor
Covenant](http://contributor-covenant.org) code of conduct. See
[here](https://github.com/matthutchinson/ecb_exchange/blob/master/CODE_OF_CONDUCT.md)
for more details.

## Todo

* Better RDoc documentation.
* A Rails app to demo this gem (e.g. with a one-click Heroku install).

## License

The code is available as open source under the terms of
[LGPL-3](https://opensource.org/licenses/LGPL-3.0).

## Links

* [Gem](http://rubygems.org/gems/ecb_exchange)
* [Travis CI](https://travis-ci.com/matthutchinson/ecb_exchange)
* [Maintainability](https://codeclimate.com/github/matthutchinson/ecb_exchange/maintainability)
* [Test Coverage](https://codeclimate.com/github/matthutchinson/ecb_exchange/test_coverage)
* [RDoc](http://rdoc.info/projects/matthutchinson/ecb_exchange)
* [Issues](http://github.com/matthutchinson/ecb_exchange/issues)
* [Report a bug](http://github.com/matthutchinson/ecb_exchange/issues/new)
* [GitHub](https://github.com/matthutchinson/ecb_exchange)
