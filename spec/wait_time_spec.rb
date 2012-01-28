require 'spec_helper'

describe "WaitTime" do
  fixtures :all
  
  it "should have 50 wait times for each branch" do
    branches(:boston).wait_times.length.should == 50
    branches(:watertown).wait_times.length.should == 50
    branches(:marthas_vineyard).wait_times.length.should == 50
  end
end