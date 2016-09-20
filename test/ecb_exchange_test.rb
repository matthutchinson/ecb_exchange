require 'test_helper'

class EcbExchangeTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ECB::Exchange::VERSION
  end
end
