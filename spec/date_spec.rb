require 'spec_helper'

describe "Date" do
  before :each do
    @params = { :name => "Boston",
               :start_date => {
                  :year => 2011,
                  :month => 10,
                  :day => 5 },
               :end_date => {
                  :year => 2011,
                  :month => 11,
                  :day => 1},
               :other_irrelevant_junk => "my face" }
  end
  
	it "should have a from_param method" do
		Date.should respond_to(:from_param)
	end
	
	it "should make a Date with year/month/day from a rails form param" do
	  Date.from_param(@params[:start_date]).should == Date.new(2011, 10, 5)
  end
  
  it "should work with all dates inside a param" do
    Date.from_param(@params[:end_date]).should == Date.new(2011, 11, 1)
  end
end