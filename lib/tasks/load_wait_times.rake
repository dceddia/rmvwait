#  Created by Dave Ceddia on 2011-10-31.
#  Copyright (c) 2011. All rights reserved.

require 'chronic_duration'

def valid_line?
  line =~ /^[A-Z].*2011$/ && !(line =~ /Technical difficulties/) && line.split('|').length == 5
end

desc "Load wait times from a text file"
task :load_wait_times, :filename do |t, args|
  if args[:filename] == nil
    puts "Usage: rake load_wait_times['wait_times.txt']" 
    exit
  end
  
  # Pull all the valid lines from the file
  File.open(args[:filename], 'r') do |f| 
    f.each_line do |line| 
      next unless valid_line?(line)
      town, license_wait, registration_wait, reported_time, retrieved_at = line.split('|')

      license_duration = RMVDuration.parse(license_wait)
      registration_duration = RMVDuration.parse(registration_wait)
      reported_time = Time.parse(reported_time)
      reported_at = DateTime.parse(retrieved_at).change(:hour => reported_time.hour, 
                                                        :min => reported_time.min)
      puts "#{town} | #{license_duration} | #{registration_duration} | #{reported_at}"
    end
  end
end
