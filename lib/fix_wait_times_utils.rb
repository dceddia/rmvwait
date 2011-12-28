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
  class DiscardFilter
    def modify(line)
      should_discard?(line) ? nil : line
    end
    
    def should_discard?(line)
      false
    end
  end
  
  class DiscardMalformedLine < DiscardFilter
    def should_discard?(line)
      (line !~ /^[A-Z].*20\d\d$/ || line.split("|").length != 5) ? true : false
    end
  end

  class DiscardBadStatusLine < DiscardFilter
    def should_discard?(line)
      (line =~ /Technical difficulties/ || line =~ /Closed/) ? true : false
    end
  end
  
  class DiscardSameAsLast < DiscardFilter
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

  class DiscardFutureAndPastReports < DiscardFilter
    MaxAge = 1200 # seconds
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
             << WaitTimeFilters::FixOct17_18_19_20_24.new \
             << WaitTimeFilters::DiscardFutureAndPastReports.new
  end
  
  def parse_line(line)
    orig_line = line.dup
    @filters.each do |f| 
      line = f.modify(line)
      
      if line.nil?
        return nil 
      end
    end
    line
  end
  
  def parse_file(filename)
    File.new(filename).readlines.each do |line|
      line.strip!
      result = parse_line(line)
      result ? puts(result) : $stderr.puts(line)
    end
  end
end