require 'date'

Date.class_eval do
  def self.days_in_month(month, year = nil)
    year = year || Date.today.year
    (Date.new(year, 12, 31) << (12-month)).day
  end

  def self.from_param(param)
    Date.civil(param[:year].to_i, param[:month].to_i, param[:day].to_i)
  end
end
