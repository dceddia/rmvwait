class Branch < ActiveRecord::Base
  has_many :wait_times
  
  def wait_times_in_range(start, stop)
    wait_times.where("reported_at >= ? AND reported_at <= ?", start, stop)
  end
  
  def wait_times_for_month(month, year = nil)
    year = year || Date.today.year
    start_date = Date.parse("#{year}-#{month}-01")
    stop_date = Date.parse("#{year}-#{month}-#{Date.days_in_month(month, year)}")
    wait_times_in_range(start_date, stop_date)
  end
end
