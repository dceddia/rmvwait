class Branch < ActiveRecord::Base
  has_many :wait_times
  
  def wait_times_in_range(start, stop)
    divide_into_categories(wait_times.where("reported_at >= ? AND reported_at <= ?", start, stop))
  end
  
  def wait_times_for_date(year, month, day)
    d = DateTime.new(year, month, day)
    wait_times_in_range(d.beginning_of_day, d.end_of_day)
  end
  
  def wait_times_for_month(month, year = nil)
    year = year || Date.today.year
    start_date = Date.parse("#{year}-#{month}-01")
    stop_date = Date.parse("#{year}-#{month}-#{Date.days_in_month(month, year)}")
    wait_times_in_range(start_date, stop_date)
  end

  def divide_into_categories(times)
    result = [[], []]
    times.each do |t| 
      case t.kind
        when 'licensing'
          result[0] << t
        when 'registration'
          result[1] << t
      end
    end
    return result
  end
end
