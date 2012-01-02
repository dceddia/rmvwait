#!/usr/bin/ruby

require 'benchmark'

lines = File.readlines("split_data")

split1_result = []
split2_result = []
regex_result = []
count_result = []

Benchmark.bm(5) do |bm|
  bm.report { lines.each { |l| split1_result << l.split('|') } }
  bm.report { lines.each { |l| split2_result << l.split(/|/) } }
  bm.report { lines.each { |l| l =~ /(.*)|(.*)|(.*)|(.*)|(.*)/; regex_result << [$1, $2, $3, $4, $5] } }
  bm.report { lines.each { |l| count_result << l.count('|') } }
end
