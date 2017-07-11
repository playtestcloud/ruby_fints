require 'test_helper'

class SegmentTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::FinTS::VERSION
  end
end
