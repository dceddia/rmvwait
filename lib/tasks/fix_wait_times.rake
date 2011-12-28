#!/usr/bin/ruby

require 'date'
require 'fix_wait_times_utils'

desc "Fix wait times (remove dupes and bad ones, etc)"
task :fix_wait_times, [:filename] => [:environment] do |t, args|
  if args[:filename] == nil
    puts "Usage: rake fix_wait_times['wait_times.txt']" 
    exit
  end
  
  wtf = WaitTimeFixer.new
  wtf.parse_file(args[:filename])
end