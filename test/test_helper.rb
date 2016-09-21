$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ecb/exchange'
require 'exchange_rate'
require 'minitest/autorun'
require 'webmock/minitest'

# helper to load fixtures
FIXTURE_DIR = File.expand_path(File.dirname(__FILE__)+"/fixtures/")
def response_fixture(filename)
  File.read("#{FIXTURE_DIR}/responses/#{filename}")
end

# helper to access the cache
def cache
  ECB::Exchange::Cache
end

# always use an in memory cache for tests
require "active_support"
cache.backend = ActiveSupport::Cache::MemoryStore.new
