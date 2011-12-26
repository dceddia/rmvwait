require 'test_helper'
require 'fix_wait_times_utils'

class FixWaitTimesTest < ActiveSupport::TestCase
  def bad_line
    "Complete junk"
  end
 
  def tech_difficulties_line
    "Boston|Technical difficulties|Technical difficulties|3:46 PM|Wed Aug 31 15:48:59 -0400 2011"
  end

  def closed_line
    "Boston|Closed|Closed|3:46 PM|Wed Aug 31 15:48:59 -0400 2011"
  end
  
  def good_line
    "Springfield|5 minutes, 34 seconds|13 minutes, 8 seconds|3:46 PM|Wed Aug 31 15:48:59 -0400 2011"
  end

  def too_far_past_line
    "Springfield|5 minutes, 34 seconds|13 minutes, 8 seconds|3:00 PM|Wed Aug 31 15:10:01 -0400 2011"
  end
  
  def too_far_future_line
    "Springfield|5 minutes, 34 seconds|13 minutes, 8 seconds|3:00 PM|Wed Aug 31 14:58:59 -0400 2011"
  end
  
  def line_with_n_fields(n)
    str = ""
    n.times do |i|
      str += "field{i}"
      str += "|" if i != n - 1
    end
    return str
  end
  
  test "DiscardMalformedLine filter" do
    f = WaitTimeFilters::DiscardMalformedLine.new
    assert f.should_discard?(bad_line)
    (1..4).each { |n| assert f.should_discard?(line_with_n_fields(n)) }
    (6..10).each { |n| assert f.should_discard?(line_with_n_fields(n)) }
    
    assert_equal false, f.should_discard?(tech_difficulties_line)
    assert_equal false, f.should_discard?(closed_line)
    assert_equal false, f.should_discard?(good_line)
  end
  
  test "DiscardBadStatusLine filter" do
    f = WaitTimeFilters::DiscardBadStatusLine.new
    assert f.should_discard?(tech_difficulties_line)
    assert f.should_discard?(closed_line)
    
    assert_equal false, f.should_discard?(good_line)
    assert_equal false, f.should_discard?(bad_line) # DiscardMalformedLine should handle this
  end
end