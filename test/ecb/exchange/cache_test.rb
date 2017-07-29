require File.expand_path(File.dirname(__FILE__)+'../../../test_helper')

describe ECB::Exchange::Cache do

  it 'should read/write from the cache backend with a key prefix' do
    assert_nil cache.read('some-key')

    cache.write('some-key', 'some-value')
    assert_equal cache.read('some-key'), 'some-value'
    assert_equal cache.backend.read("#{cache::KEY_PREFIX}some-key"), 'some-value'
  end

  it 'should clear the cache backend' do
    cache.write('some-key', 'some-value')
    assert_equal cache.read('some-key'), 'some-value'

    cache.clear
    assert_nil cache.read('some-key')
  end

  describe 'configuring cache' do
    before do
      @default_cache_store = cache.backend
    end

    it 'should allow the cache backend to be configured' do
      dummy_cache = OpenStruct.new

      cache.backend = dummy_cache
      assert_equal cache.backend, dummy_cache
    end

    after do
      cache.backend = @default_cache_store
    end
  end
end
