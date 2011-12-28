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
=begin
  test "return wait times for single day" do
    start = DateTime.parse('Oct 3 2011 00:00:00')
    stop = DateTime.parse('Oct 3 2011 23:59:59')
    puts "first time reported at: #{@branch.wait_times.first.reported_at} (looking for #{start} to #{stop})"
    puts "this says #{@branch.wait_times.first.reported_at >= start} and #{@branch.wait_times.first.reported_at <= stop}"
    licensing, registration = @branch.wait_times_in_range(start, stop)
    assert_equal 5, licensing.length
    assert_equal 5, registration.length
  end
=end
end
