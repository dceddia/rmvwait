require 'test_helper'

class WaitTimeTest < ActiveSupport::TestCase
  test "should have 50 wait times for each branch" do
    assert_equal branches(:boston).wait_times.length, 50
    assert_equal branches(:watertown).wait_times.length, 50
    assert_equal branches(:marthas_vineyard).wait_times.length, 50
  end
end
