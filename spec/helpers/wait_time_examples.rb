module WaitTimeExamples
  def bad_line
    "total junk"
  end
  
  def good_line
    "Boston|5 minutes, 34 seconds|13 minutes, 8 seconds|3:46 PM|Wed Aug 31 15:48:59 -0400 2011"
  end

  def good_line_utc
    "Boston|5 minutes, 34 seconds|13 minutes, 8 seconds|2011-08-31T19:46:00+00:00|2011-08-31T19:48:59+00:00"
  end
  def good_line_elsewhere
    "Watertown|5 minutes, 34 seconds|13 minutes, 8 seconds|3:46 PM|Wed Aug 31 15:48:59 -0400 2011"
  end
  def good_line_elsewhere_utc
    "Watertown|5 minutes, 34 seconds|13 minutes, 8 seconds|2011-08-31T19:46:00+00:00|2011-08-31T19:48:59+00:00"
  end   
  
  def good_line_earlier
    "Boston|5 minutes, 34 seconds|13 minutes, 8 seconds|3:45 PM|Wed Aug 31 15:48:59 -0400 2011"
  end
  def good_line_earlier_utc
    "Boston|5 minutes, 34 seconds|13 minutes, 8 seconds|2011-08-31T19:45:00+00:00|2011-08-31T19:48:59+00:00"
  end
  
  def good_line_later
    "Springfield|5 minutes, 34 seconds|13 minutes, 8 seconds|3:47 PM|Wed Aug 31 15:48:59 -0400 2011"
  end
  def good_line_later_utc
    "Springfield|5 minutes, 34 seconds|13 minutes, 8 seconds|2011-08-31T19:47:00+00:00|2011-08-31T19:48:59+00:00"
  end  
  def tech_difficulties_line
    "Boston|Technical difficulties|Technical difficulties|3:46 PM|Wed Aug 31 15:52:59 -0400 2011"
  end

  def closed_line
    "Boston|Closed|Closed|3:46 PM|Wed Aug 31 15:48:59 -0400 2011"
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
  def not_too_far_past_line_utc
    "Springfield|5 minutes, 34 seconds|13 minutes, 8 seconds|2011-08-31T19:10:00+00:00|2011-08-31T19:30:00+00:00"
  end

  def not_too_far_future_line
    "Springfield|5 minutes, 34 seconds|13 minutes, 8 seconds|3:15 PM|Wed Aug 31 15:14:00 -0400 2011"
  end
  def not_too_far_future_line_utc
    "Springfield|5 minutes, 34 seconds|13 minutes, 8 seconds|2011-08-31T19:15:00+00:00|2011-08-31T19:14:00+00:00"
  end
end
