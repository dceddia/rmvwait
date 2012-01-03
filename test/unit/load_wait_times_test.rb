require 'test_helper'

class LoadWaitTimesTest < ActiveSupport::TestCase
  def bad_line
    "Complete junk"
  end
 
  def tech_difficulties_line
    "Boston|Technical difficulties|Technical difficulties|3:46 PM|Wed Aug 31 15:52:59 -0400 2011"
  end

  def closed_line
    "Boston|Closed|Closed|3:46 PM|Wed Aug 31 15:48:59 -0400 2011"
  end
  
  def good_line_utc
    "Watertown|5 minutes, 34 seconds|13 minutes, 8 seconds|2011-08-31T19:46:00+00:00|2011-08-31T19:48:59+00:00"
  end
  
  def good_line_elsewhere_utc
    "Boston|5 minutes, 34 seconds|13 minutes, 8 seconds|2011-08-31T19:46:00+00:00|2011-08-31T19:48:59+00:00"
  end  

  def verify_time(line, wait_time, kind)
    branch_name, licensing_wait, registration_wait, reported_time, retrieved_at = line.split("|")
    licensing_duration = RMVDuration.parse(licensing_wait)
    registration_duration = RMVDuration.parse(registration_wait)
    reported_time = DateTime.parse(reported_time).utc
    reported_at = DateTime.parse(retrieved_at).change(:hour => reported_time.hour, 
                                                      :min => reported_time.min).utc
    branch = Branch.where(:human_name => branch_name).first
    assert branch == wait_time.branch
    assert reported_at == wait_time.reported_at
    if kind == :licensing
      assert licensing_duration == wait_time.duration
    elsif kind == :duration
      assert registration_duration == wait_time.duration
    end
  end
  
  test "should reject bad lines" do
    wtl = WaitTimeUtils::WaitTimeLoader.new
    times_already_loaded = WaitTime.find(:all).length
    assert_equal false, wtl.load_line(bad_line)
    assert_equal false, wtl.load_line(tech_difficulties_line)
    assert_equal false, wtl.load_line(closed_line)
    assert_equal times_already_loaded, WaitTime.find(:all).length
  end
  
  test "should load good lines" do
    wtl = WaitTimeUtils::WaitTimeLoader.new
    times_already_loaded = WaitTime.find(:all).length
    assert wtl.load_line(good_line_utc)
    assert wtl.load_line(good_line_elsewhere_utc)
    # 2 times (licensing, registration) per line
    assert_equal times_already_loaded + 4, WaitTime.find(:all).length
    lic1, reg1, lic2, reg2 = WaitTime.find(:all).last(4)
    verify_time(good_line_utc, lic1, :licensing)
    verify_time(good_line_utc, reg1, :registration)
    verify_time(good_line_elsewhere_utc, lic2, :licensing)
    verify_time(good_line_elsewhere_utc, reg2, :registration)
  end
  
  test "batch mode should work" do
    times_already_loaded = WaitTime.find(:all).length
    wtl = WaitTimeUtils::WaitTimeLoader.new(1000)
    5.times { wtl.load_line(good_line_utc) }
    assert_equal times_already_loaded, WaitTime.find(:all).length
    wtl.send_batch(true)
    assert_equal times_already_loaded + 10, WaitTime.find(:all).length
  end
end