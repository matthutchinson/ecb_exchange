require 'ecb_exchange'
require 'minitest/autorun'
require 'webmock/minitest'

def valid_xml_response
  xml_response("eurofxref-hist-90d.xml")
end

def xml_response(filename)
  fixture_dir = File.expand_path(File.dirname(__FILE__)+"/fixtures/")
  File.read("#{fixture_dir}/responses/#{filename}")
end

def with_today_as(yyyy_mm_dd)
  Date.stub(:today, Date.parse(yyyy_mm_dd)) do
    yield
  end
end

def cache
  ECB::Exchange::Cache
end

def clear_cache
  cache.store.clear
end
