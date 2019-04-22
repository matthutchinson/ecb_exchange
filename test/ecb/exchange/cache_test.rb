# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + "../../../test_helper")

class ECB::ExchangeCache < Minitest::Test
  def setup
    cache.backend = nil
    clear_cache
  end

  def test_writing_and_reading_from_backend_with_key_prefix
    assert_nil cache.read('some-key')

    cache.write('some-key', 'some-value')
    assert_equal cache.read('some-key'), 'some-value'
    assert_equal cache.store.read("#{cache::KEY_PREFIX}-some-key"), 'some-value'
  end

  def test_uses_backend_cache_if_set
    cache.backend = HashCache.cache
    assert_kind_of HashCache, cache.store
  end

  def test_uses_backend_cache_if_set_and_rails_cache_available
    cache.backend = HashCache.cache
    Rails.stub(:cache, RailsCache.cache) do
      assert_kind_of HashCache, cache.store
    end
  end

  def test_uses_rails_cache_when_available_and_no_backend_set
    Rails.stub(:cache, RailsCache.cache) do
      assert_kind_of RailsCache, cache.store
    end
  end

  def test_uses_memory_store_when_no_backend_set_or_rails_cache_available
    assert_kind_of ECB::Exchange::MemoryCache, cache.store
  end
end

# caching test classes
class HashCache < ECB::Exchange::MemoryCache; end
class RailsCache < ECB::Exchange::MemoryCache; end
# dummy Rails class
class Rails; def self.cache; end; end
