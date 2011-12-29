require 'test_helper'

class BranchTest < ActiveSupport::TestCase
  fixtures :all

  def setup
    @branch = branches(:boston)
  end

  test "has a wait_times_in_range method" do
    assert_respond_to @branch, :wait_times_in_range
  end

  test "branch should have 50 wait times" do
    assert_equal @branch.wait_times.length, 50
  end

  test "return wait times in the range of a single day" do
    # Time.parse includes the local timezone, DateTime.parse sets tz = 0
    start = Time.parse('Dec 5 2011 00:00:00')
    stop = Time.parse('Dec 5 2011 23:59:59')
    licensing, registration = @branch.wait_times_in_range(start, stop)
    assert_equal 5, licensing.length
    assert_equal 5, registration.length
  end
  
  test "return wait times for a single day" do
    licensing, registration = @branch.wait_times_for_date(2011, 12, 5)
    assert_equal 5, licensing.length
    assert_equal 5, registration.length
  end
  
  test "return wait times in the range of an entire week" do
    # Time.parse includes the local timezone, DateTime.parse sets tz = 0
    start = Time.parse('Dec 5 2011 00:00:00')
    stop = Time.parse('Dec 9 2011 23:59:59')
    licensing, registration = @branch.wait_times_in_range(start, stop)
    assert_equal 5*5, licensing.length
    assert_equal 5*5, registration.length
  end
end
