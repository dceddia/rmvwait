module WaitTimeUtils

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
        (line !~ /^[A-Z]/ || line.count("|") != 4) ? true : false
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
        report_age < MaxFuture || report_age > MaxAge
      end
    end
    
    class ChangeTimeToUTC
      def modify(line)
        branch, lic, reg, reported_time, retrieved_time = line.split("|")
        retrieved_at = DateTime.parse(retrieved_time)
        reported_at = retrieved_at.change(:hour => DateTime.parse(reported_time).hour,
                                          :min => DateTime.parse(reported_time).min)
        "#{branch}|#{lic}|#{reg}|#{reported_at.utc.to_s}|#{retrieved_at.utc.to_s}"
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
        new_line = "#{branch}|#{lic}|#{reg}|#{fixed_time.utc.to_s}|#{retrieved_time}"
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
               << WaitTimeFilters::ChangeTimeToUTC.new \
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
  
  class WaitTimeLoader
    def initialize(batch_size = 2)
      @filters = []
      @filters << WaitTimeFilters::DiscardMalformedLine.new \
               << WaitTimeFilters::DiscardBadStatusLine.new      
      @column_names = [:branch_id, :duration, :reported_at, :kind]
      @branch_cache = {}
      @wait_times = []
      @batch_size = batch_size
    end
    
    def get_branch(branch_name)
      if not @branch_cache.include?(branch_name)
        @branch_cache[branch_name] = Branch.where(:human_name => branch_name).first
      end
      @branch_cache[branch_name]
    end
       
    def send_batch(force = false)
      if force or @wait_times.length >= @batch_size
        WaitTime.import @column_names, @wait_times  
        @wait_times = []                                                    
      end
    end
    
    def load_line(line)
      orig_line = line.dup
      @filters.each do |f|
        line = f.modify(line)
        return false if line.nil?
      end
      
      branch, licensing_duration, registration_duration, reported_at, retrieved_at = parse_line(line)

      @wait_times << [branch.object_id, licensing_duration, reported_at, :licensing]
      @wait_times << [branch.object_id, registration_duration, reported_at, :registration]
      send_batch
      true
    end
    
    def parse_line(line)
      branch_name, licensing_wait, registration_wait, reported_time, retrieved_at = line.split("|")
      licensing_duration = RMVDuration.parse(licensing_wait)
      registration_duration = RMVDuration.parse(registration_wait)
      reported_time = DateTime.parse(reported_time).utc
      reported_at = DateTime.parse(retrieved_at).change(:hour => reported_time.hour, 
                                                        :min => reported_time.min).utc
      branch = get_branch(branch_name)
      [branch, licensing_duration, registration_duration, reported_at, retrieved_at]
    end
    
    def load_file(file)
      lines_total = lines_loaded = 0
      IO.foreach(file) do |line|
        lines_loaded += 1 if load_line(line)
        lines_total += 1
        if (lines_total % 1000 == 0)
          puts "Loaded %d / %d" % [lines_loaded, lines_total]
        end
      end
      send_batch(true)
      [lines_loaded, lines_total]
    end
  end
end
