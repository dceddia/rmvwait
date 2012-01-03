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
  
  wtl = WaitTimeUtils::WaitTimeLoader.new(2000)
  loaded, total = wtl.load_file(args[:filename])
  
  puts "Loaded #{loaded} of #{total} lines (%.01f)" % [(loaded.to_f / total.to_f) * 100.0]
end
