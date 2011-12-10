#  Created by Dave Ceddia on 2011-10-31.
#  Copyright (c) 2011. All rights reserved.

require 'chronic_duration'
require 'activerecord-import'

def valid_line?(line)
  line =~ /^[A-Z].*2011$/ && !(line =~ /Technical difficulties/)
end

def save_wait_time(branch, duration, reported_at, kind)
  wait_time = WaitTime.create(:branch => branch,
                              :duration => duration,
                              :reported_at => reported_at,
                              :kind => kind)
  raise unless wait_time.persisted?
end

desc "Load wait times from a text file"
task :load_wait_times, [:filename] => [:environment] do |t, args|
  if args[:filename] == nil
    puts "Usage: rake load_wait_times['wait_times.txt']" 
    exit
  end
  
  branch_cache = {}
  branch = nil
  i = 0
  wait_times = []
  IO.foreach(args[:filename]) do |line|
    next unless valid_line?(line)
    split_line = line.split('|')
    next unless split_line.length == 5
    branch_name, licensing_wait, registration_wait, reported_time, retrieved_at = split_line

    licensing_duration = RMVDuration.parse(licensing_wait)
    registration_duration = RMVDuration.parse(registration_wait)
    reported_time = Time.parse(reported_time)
    reported_at = Time.parse(retrieved_at).change(:hour => reported_time.hour, 
                                                  :min => reported_time.min)

    if branch_cache.include?(branch_name)
      branch = branch_cache[branch_name]
    else
      branch = Branch.where(:human_name => branch_name).first
      branch_cache[branch_name] = branch
    end
      
    column_names = [:branch_id, :duration, :reported_at, :kind]
    wait_times << [branch.object_id, licensing_duration, reported_at, :licensing]
    wait_times << [branch.object_id, registration_duration, reported_at, :registration]
=begin
    wait_times << WaitTime.new(:branch => branch,
                               :duration => licensing_duration,
                               :reported_at => reported_at,
                               :kind => :licensing)
    wait_times << WaitTime.new(:branch => branch,
                               :duration => registration_duration,
                               :reported_at => reported_at,
                               :kind => :registration)
=end
    if (i % 1000) == 0
      WaitTime.import column_names, wait_times
      wait_times = []
      puts "Loaded #{i}"
    end
    i += 1
  end
end
