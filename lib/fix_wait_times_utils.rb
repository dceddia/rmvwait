class RecordStore
  def initialize
    @records = {}
  end

  def duplicate?(branch, lic, reg, reported_time)
    @records[branch] == [lic, reg, reported_time]
  end

  def update(branch, lic, reg, reported_time)
    @records[branch] = [lic, reg, reported_time]
  end
end

module WaitTimeFilters
  class DiscardMalformedLine
    def should_discard?(line)
      (line !~ /^[A-Z].*20\d\d$/ || line.split("|").length != 5) ? true : false
    end
  end

  class DiscardBadStatusLine
    def should_discard?(line)
      (line =~ /Technical difficulties/ || line =~ /Closed/) ? true : false
    end
  end
  
  class DiscardSameAsLast
    def initialize
      @records = RecordStore.new
    end

    def should_discard?(line)
      branch, lic, reg, reported_time = line.split("|")
      return true if @records.duplicate?(branch, lic, reg, reported_time)
      @records.update(branch, lic, reg, reported_time)
      false
    end
  end

  class DiscardFutureAndPastReports
    MaxAge = 600 # seconds
    MaxFuture = -60 # seconds in the future, always negative
    def should_discard?(line)
      branch, lic, reg, reported_time, retrieved_time = line.split("|")

      retrieved_at = DateTime.parse(retrieved_time)
      reported_at = retrieved_at.change(:hour => DateTime.parse(reported_time).hour,
                                        :min => DateTime.parse(reported_time).min)
      report_age = ((retrieved_at - reported_at) * 24 * 60 * 60).to_i
=begin    
      if report_age < MaxFuture || report_age > MaxAge
        puts "#{branch}|#{lic}|#{reg}|#{reported_time}|#{retrieved_time}"
        if report_age < MaxFuture
          puts "   reported in the future??? #{report_age}" 
          future_reports += 1
        end
        if report_age > MaxAge
          puts "   very old report: #{report_age}" 
          old_reports += 1
        end
      end
=end
      report_age < MaxFuture || report_age > MaxAge
    end
  end
end

module WaitTimeModifiers
  class FixOct17_18_19_20_24
    def modify(line)
      branch, lic, reg, reported_time, retrieved_time = line.split("|")
      retrieved_at = DateTime.parse(retrieved_time)
      return line unless retrieved_at.year == 2011
      return line unless retrieved_at.month == 10 
      return line unless [17, 18, 19, 20, 24].include?(retrieved_at.day)
      # These 5 days in Oct 2011, RMV's time was off by 5 hours. Add 5 hours.
      reported_at = retrieved_at.change(:hour => DateTime.parse(reported_time).hour,
                                        :min => DateTime.parse(reported_time).min)
      fixed_time = reported_at + Rational(5,24)
      new_line = "#{branch}|#{lic}|#{reg}|#{fixed_time.strftime("%l:%M %p").strip}|#{retrieved_time}"
      #puts "'#{line}' => '#{new_line}'"
      return new_line
    end
  end
end

class WaitTimeFixer
  def initialize
    @filters = []
    @filters << WaitTimeFilters::DiscardMalformedLine.new \
             << WaitTimeFilters::DiscardBadStatusLine.new \
             << WaitTimeFilters::DiscardSameAsLast.new \
             << WaitTimeFilters::DiscardFutureAndPastReports.new

    @modifiers = []
    @modifiers << WaitTimeModifiers::FixOct17_18_19_20_24.new    
  end
  
  def parse_line(line)
    return nil if @filters.any? { |f| f.should_discard?(line) }
    @modifiers.each { |m| line = m.modify(line) }
    line
  end
end