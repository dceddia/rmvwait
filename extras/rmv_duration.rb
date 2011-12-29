#  Created by Dave Ceddia on 2011-11-01.
#  Copyright (c) 2011. All rights reserved.

module RMVDuration
  # Wayyy faster than ChronicDuration.parse
  # about .08 seconds for 5000 records vs 6.7 seconds
  def parse(str)
    days = (str =~ /(\d+)\s+?d/) ? $1.to_i : 0
    hours = (str =~ /(\d+)\s+?h/) ? $1.to_i : 0
    minutes = (str =~ /(\d+)\s+?m/) ? $1.to_i : 0
    seconds = (str =~ /(\d+)\s+?s/) ? $1.to_i : 0
    seconds + minutes*60 + hours*3600 + days*86400
  end

  def output(time_string)
    ChronicDuration.output(time_string)
  end
  
  module_function :parse, :output
end
