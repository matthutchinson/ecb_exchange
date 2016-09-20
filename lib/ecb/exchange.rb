require 'ecb/exchange/version'
require 'ecb/exchange/xml_feed'
require 'ecb/exchange/convertor'
require 'ecb/exchange/cache'
require 'ecb/exchange/errors'


# TODO - remove me
require "active_support"
ECB::Exchange::Cache.backend = ActiveSupport::Cache::MemoryStore.new
