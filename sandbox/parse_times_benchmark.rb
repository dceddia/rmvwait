#!/usr/bin/ruby

require 'rubygems'
require 'chronic_duration'
require 'benchmark'

def parse_time(str)
  days = (str =~ /(\d+)\s+?d/) ? $1.to_i : 0
  hours = (str =~ /(\d+)\s+?h/) ? $1.to_i : 0
  minutes = (str =~ /(\d+)\s+?m/) ? $1.to_i : 0
  seconds = (str =~ /(\d+)\s+?s/) ? $1.to_i : 0
  seconds + minutes*60 + hours*3600 + days*86400
end

times = File.readlines("times")

chronic_result = []
custom_result = []
Benchmark.bm(20) do |x|
  x.report("chronic_duration:") { 
    times.each { |t| chronic_result << (ChronicDuration.parse(t) || 0) }
  }
  x.report("custom parser:") { 
    times.each { |t| custom_result << parse_time(t) }
  }
end

puts chronic_result == custom_result
