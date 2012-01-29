require 'spec_helper'

describe "WaitTimeLoader" do
  include WaitTimeExamples
  fixtures :branches
  
	before(:each) do
	  @loader = WaitTimeUtils::WaitTimeLoader.new
  end
  
  it "should not load bad lines" do
    lambda {
      @loader.load_line(bad_line)
      @loader.load_line(tech_difficulties_line)
      @loader.load_line(closed_line)
    }.should_not change { WaitTime.count }
  end
  
  it "should load good lines" do
    lambda {
      @loader.load_line(good_line_utc)
      @loader.load_line(good_line_elsewhere_utc)
    }.should change { WaitTime.count }.by(4)
  end
  
  it "should load lines in batch mode" do
    @loader = WaitTimeUtils::WaitTimeLoader.new(1000)
    lambda {
      # queue up records, but shouldn't save yet
      5.times { @loader.load_line(good_line_utc) }  
    }.should_not change { WaitTime.count }
    lambda {
      # should not save unless forced (10 records < 1000 minimum)
      @loader.send_batch
    }.should_not change {WaitTime.count}
    lambda {
      @loader.send_batch(true) # force == true
    }.should change { WaitTime.count }.by(10)
  end
end