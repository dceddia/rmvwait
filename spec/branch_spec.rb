require 'spec_helper'

describe Branch do
  fixtures :all
  
  before :each do
    @branch = branches(:boston)
  end
  
	it "should have a wait_times_in_range instance method" do
		@branch.should respond_to(:wait_times_in_range)
		Branch.should_not respond_to(:wait_times_in_range)
	end
	
	it "should have 50 wait times" do
	  @branch.wait_times.length.should == 50
  end
  
  it "should return wait times for a single day" do
    # Time.parse uses the local timezone, DateTime.parse sets tz = 0
    start = DateTime.parse('Dec 5 2011 00:00:00')
    stop = DateTime.parse('Dec 5 2011 23:59:59')
    licensing, registration = @branch.wait_times_in_range(start, stop)
  
    licensing.length.should == 5
    registration.length.should == 5
  end
  
  it "should return wait times for a single date" do
    licensing, registration = @branch.wait_times_for_date(2011, 12, 5)
    licensing.length.should == 5
    registration.length.should == 5
  end
  
  it "should return wait times in the range of an entire week" do
    # Time.parse includes the local timezone, DateTime.parse sets tz = 0
    start = Time.parse('Dec 5 2011 00:00:00')
    stop = Time.parse('Dec 9 2011 23:59:59')
    licensing, registration = @branch.wait_times_in_range(start, stop)
    licensing.length.should == 5*5
    registration.length.should == 5*5
  end
end