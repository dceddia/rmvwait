require 'test_helper'
require 'fix_wait_times_utils'

class FixWaitTimesTest < ActiveSupport::TestCase
  def bad_line
    "Complete junk"
  end
 
  def tech_difficulties_line
    "Boston|Technical difficulties|Technical difficulties|3:46 PM|Wed Aug 31 15:52:59 -0400 2011"
  end

  def closed_line
    "Boston|Closed|Closed|3:46 PM|Wed Aug 31 15:48:59 -0400 2011"
  end
  
  def good_line
    "Springfield|5 minutes, 34 seconds|13 minutes, 8 seconds|3:46 PM|Wed Aug 31 15:48:59 -0400 2011"
  end
  
  def good_line_elsewhere
    "Boston|5 minutes, 34 seconds|13 minutes, 8 seconds|3:46 PM|Wed Aug 31 15:48:59 -0400 2011"
  end
   
  def good_line_earlier
    "Springfield|5 minutes, 34 seconds|13 minutes, 8 seconds|3:45 PM|Wed Aug 31 15:48:59 -0400 2011"
  end

  def good_line_later
    "Springfield|5 minutes, 34 seconds|13 minutes, 8 seconds|3:47 PM|Wed Aug 31 15:48:59 -0400 2011"
  end
    
  def too_far_past_line
    "Springfield|5 minutes, 34 seconds|13 minutes, 8 seconds|3:00 PM|Wed Aug 31 15:20:01 -0400 2011"
  end
  
  def too_far_future_line
    "Springfield|5 minutes, 34 seconds|13 minutes, 8 seconds|3:00 PM|Wed Aug 31 14:58:59 -0400 2011"
  end

  def not_too_far_past_line
    "Springfield|5 minutes, 34 seconds|13 minutes, 8 seconds|3:10 PM|Wed Aug 31 15:30:00 -0400 2011"
  end
  
  def not_too_far_future_line
    "Springfield|5 minutes, 34 seconds|13 minutes, 8 seconds|3:15 PM|Wed Aug 31 15:14:00 -0400 2011"
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
  
  test "DiscardSameAsLast filter simple duplicate" do
    f = WaitTimeFilters::DiscardSameAsLast.new
    
    assert_equal false, f.should_discard?(good_line)
    assert_equal true, f.should_discard?(good_line)
  end

  test "DiscardSameAsLast filter non-duplicate" do
    f = WaitTimeFilters::DiscardSameAsLast.new
    
    assert_equal false, f.should_discard?(good_line)
    assert_equal false, f.should_discard?(good_line_elsewhere)
  end
  
  test "DiscardSameAsLast filter same branch, different time" do
    f = WaitTimeFilters::DiscardSameAsLast.new
    
    assert_equal false, f.should_discard?(good_line)
    assert_equal false, f.should_discard?(good_line_earlier)
    assert_equal false, f.should_discard?(good_line)
  end

  test "DiscardSameAsLast filter different branch, same time" do
    f = WaitTimeFilters::DiscardSameAsLast.new
    
    assert_equal false, f.should_discard?(good_line)
    assert_equal false, f.should_discard?(good_line_elsewhere)
    assert_equal true, f.should_discard?(good_line)
  end
  
  test "DiscardFutureAndPastReports filter" do
    f = WaitTimeFilters::DiscardFutureAndPastReports.new
    
    assert_equal false, f.should_discard?(good_line)
    assert f.should_discard?(too_far_future_line)
    assert f.should_discard?(too_far_past_line)
  end
  
  def october_examples
    lines = []
    days = [17, 18, 19, 20, 24]
    days.each do |day|
      date_string = DateTime.new(2011, 10, day, 10, 30, 00, Rational(4, 24)).to_s
      lines << "Boston|1 hour|1 hour|5:24 AM|#{date_string}"
    end
    lines
  end
  
  test "Fix October problems" do
    f = WaitTimeFilters::FixOct17_18_19_20_24.new
    october_examples.each do |ex|
      t1 = Time.parse(ex.split("|")[3])
      fixed_ex = f.modify(ex)
      t2 = Time.parse(fixed_ex.split("|")[3])
      assert_in_delta 5.0 * 60.0 * 60.0, (t2 - t1), 0.001
    end
  end

  test "Don't fix anything but problematic October dates" do
    f = WaitTimeFilters::FixOct17_18_19_20_24.new
    examples = []
    # one year later
    examples << "Boston|1 hour|1 hour|5:24 AM|#{DateTime.new(2012, 10, 17, 10, 30, 00, Rational(4,24)).to_s}"
    # one year before
    examples << "Boston|1 hour|1 hour|5:24 AM|#{DateTime.new(2010, 10, 17, 10, 30, 00, Rational(4,24)).to_s}"
    # unaffected days
    examples << "Boston|1 hour|1 hour|5:24 AM|#{DateTime.new(2011, 10, 16, 10, 30, 00, Rational(4,24)).to_s}"
    examples << "Boston|1 hour|1 hour|5:24 AM|#{DateTime.new(2011, 10, 21, 10, 30, 00, Rational(4,24)).to_s}"
    
    examples.each do |ex|
      t1 = Time.parse(ex.split("|")[3])
      t2 = Time.parse(f.modify(ex).split("|")[3])
      assert_equal t1, t2
    end
  end
  
  test "Fix some wait times" do
    f = WaitTimeFixer.new
    
    # Normal operation
    assert_equal good_line, f.parse_line(good_line)
    
    # Throw out bad lines
    assert_nil f.parse_line(bad_line)

    # Throw out duplicates
    assert_nil f.parse_line(good_line)
  
    # Try a real October time
    oct_orig = "Worcester|No wait time|6 minutes, 44 seconds|2:57 AM|Mon Oct 24 08:10:09 -0400 2011"
    oct_fixed = "Worcester|No wait time|6 minutes, 44 seconds|7:57 AM|Mon Oct 24 08:10:09 -0400 2011"
    assert_equal oct_fixed, f.parse_line(oct_orig)
  

    # Try another real October time
    oct_orig = "Brockton|No wait time|No wait time|3:19 AM|Wed Oct 19 08:32:15 -0400 2011"
    oct_fixed = "Brockton|No wait time|No wait time|8:19 AM|Wed Oct 19 08:32:15 -0400 2011"
    assert_equal oct_fixed, f.parse_line(oct_orig)
    
    # Try everything else
    assert_nil f.parse_line(tech_difficulties_line)
    assert_nil f.parse_line(closed_line)
    assert_equal good_line_elsewhere, f.parse_line(good_line_elsewhere)
    assert_equal good_line_earlier, f.parse_line(good_line_earlier)
    assert_equal good_line_later, f.parse_line(good_line_later)
    assert_nil f.parse_line(too_far_past_line)
    assert_nil f.parse_line(too_far_future_line)
    assert_equal not_too_far_past_line, f.parse_line(not_too_far_past_line)
    assert_equal not_too_far_future_line, f.parse_line(not_too_far_future_line)
  end
end