module BranchHelper
  def seconds_to_human_duration(sec)
    RMVDuration.output(sec)
  end
  
  def human_time_of_day(datetime)
    datetime.in_time_zone(Time.zone).strftime("%H:%M %p")
  end
end
