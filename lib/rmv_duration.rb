#  Created by Dave Ceddia on 2011-11-01.
#  Copyright (c) 2011. All rights reserved.

module RMVDuration
  include ChronicDuration
  
  def parse(time_string)
    ChronicDuration.parse(time_string) || 0
  end
  
  def output(time_string)
    ChronicDuration.output(time_string)
  end
  
  module_function :parse, :output
end
