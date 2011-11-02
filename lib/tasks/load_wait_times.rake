#  Created by Dave Ceddia on 2011-10-31.
#  Copyright (c) 2011. All rights reserved.

require 'chronic_duration'

def valid_line?(line)
  line =~ /^[A-Z].*2011$/ && !(line =~ /Technical difficulties/)
end

desc "Load wait times from a text file"
task :load_wait_times, [:filename] => [:environment] do |t, args|
  if args[:filename] == nil
    puts "Usage: rake load_wait_times['wait_times.txt']" 
    exit
  end
  
  # Pull all the valid lines from the file
  times = []
  File.open(args[:filename], 'r') do |f| 
    lines = f.readlines
    puts "Read #{lines.length} lines"
    lines.each do |line| 
      next unless valid_line?(line)
      split_line = line.split('|')
      next unless split_line.length == 5
      branch_name, licensing_wait, registration_wait, reported_time, retrieved_at = split_line

      licensing_duration = RMVDuration.parse(licensing_wait)
      registration_duration = RMVDuration.parse(registration_wait)
      reported_time = Time.parse(reported_time)
      reported_at = DateTime.parse(retrieved_at).change(:hour => reported_time.hour, 
                                                        :min => reported_time.min)
      
      #puts "#{branch_name} | #{licensing_duration} | #{registration_duration} | #{reported_at}"
      times << [branch_name, licensing_duration, reported_at, :licensing]
      times << [branch_name, registration_duration, reported_at, :registration]
    end
  end
  
  puts "Loaded #{times.size} wait times"

  # sort the times by branch name to make it faster
  times.sort! { |a, b| a[0] <=> b[0] }
  
  puts "Done sorting wait times"
  
  exit if times.length == 0
  
  # add the times to the database
  branch = Branch.where(:name => times[0][0]).first
  times.each do |t|
    branch_name, duration, reported_at, kind = t
    branch = Branch.where(:name => branch_name).first if branch.name != branch_name
    wait_time = WaitTime.create(:branch => branch,
                                :duration => duration,
                                :reported_at => reported_at,
                                :kind => kind)
    raise unless wait_time.persisted?
  end
end
