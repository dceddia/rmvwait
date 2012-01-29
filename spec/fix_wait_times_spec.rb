require 'spec_helper'

describe "WaitTimeUtils" do
  include WaitTimeExamples
  
  context "DiscardMalformedLine filter" do
    before(:each) do
      @filter = WaitTimeUtils::WaitTimeFilters::DiscardMalformedLine.new
    end

    def line_with_n_fields(n)
      n.times.inject("") { |str, i| str + "Field#{i}#{'|' if i < n-1}" }
    end

    
    it "discards obviously malformed lines" do
  		@filter.discard?("total junk").should be_true
  	end
  	
  	it "discards lines with the wrong number of fields" do
  	  (1..4).each { |n| @filter.discard?(line_with_n_fields(n)).should be_true }
  	  (6..10).each { |n| @filter.discard?(line_with_n_fields(n)).should be_true }
	  end
	  
	  it "discards lines that don't start with a capital letter" do
	    @filter.discard?("9|b|c|d|e").should be_true
	    @filter.discard?("a|b|c|d|e").should be_true
	    @filter.discard?("<|b|c|d|e").should be_true
    end
    
	  it "keeps lines with 5 fields" do
	    @filter.discard?(line_with_n_fields(5)).should be_false
    end
  end
  
  context "DiscardBadStatusLine filter" do
    before(:each) do
      @filter = WaitTimeUtils::WaitTimeFilters::DiscardBadStatusLine.new
    end
    
    it "discards lines that contain 'Closed'" do
      @filter.discard?("Closed").should be_true
    end
    
    it "discards lines that contain 'Technical difficulties'" do
      @filter.discard?("Technical difficulties").should be_true
    end
    
    it "keeps lines that have other statuses" do
      @filter.discard?("A|b|c|d|e").should be_false
    end
  end

  context "DiscardSameAsLast filter" do
    before(:each) do
      @filter = WaitTimeUtils::WaitTimeFilters::DiscardSameAsLast.new
    end
    
    it "discards a line that is a duplicate of the last one" do
      line = "A|b|c|d|e"
      @filter.discard?(line).should be_false
      @filter.discard?(line).should be_true
      @filter.discard?(line).should be_true
    end
    
    it "discards duplicates of the same branch" do
      branch_a = "A|1|2|3|4"
      branch_b = "B|1|2|3|4"
      @filter.discard?(branch_a).should be_false
      @filter.discard?(branch_b).should be_false
      @filter.discard?(branch_a).should be_true
    end
    
    it "only remembers one previous entry for each branch" do
      branch_a1 = "A|1|2|3|4"
      branch_a2 = "A|x|y|z|q"
      @filter.discard?(branch_a1).should be_false
      @filter.discard?(branch_a2).should be_false
      @filter.discard?(branch_a1).should be_false
    end
    
    it "doesn't discard non-duplicate lines" do
      branch_a1 = "A|1|2|3|4"
      branch_a2 = "A|x|y|z|q"
      @filter.discard?(branch_a1).should be_false
      @filter.discard?(branch_a2).should be_false      
    end
  end
  
  context "FixOct17_18_19_20_24 filter" do
    def october_examples
      lines = []
      days = [17, 18, 19, 20, 24]
      days.each do |day|
        reported_at = DateTime.new(2011, 10, day, 5, 24, 00, Rational(4, 24))
        retrieved_at = DateTime.new(2011, 10, day, 10, 30, 00, Rational(4, 24))
        lines << "Boston|1 hour|1 hour|#{reported_at.utc}|#{retrieved_at.utc}"
      end
      lines
    end

    before(:each) do
      @filter = WaitTimeUtils::WaitTimeFilters::FixOct17_18_19_20_24.new
    end
    
    it "should add 5 hours to the times from certain Oct 2011 dates" do
      october_examples.each do |ex|
        t1 = Time.parse(ex.split("|")[3])
        fixed_ex = @filter.modify(ex)
        t2 = Time.parse(fixed_ex.split("|")[3])
        (t2 - t1).should be_within(0.001).of(5.0 * 60.0 * 60.0)
      end
    end
    
    it "should not affect dates other than Oct 17, 18, 19, 20, 24 (2011)" do
      examples = []
      # one year later
      examples << "Boston|1 hour|1 hour|5:24 AM|#{DateTime.new(2012, 10, 17, 10, 30, 00, Rational(4,24))}"
      # one year before
      examples << "Boston|1 hour|1 hour|5:24 AM|#{DateTime.new(2010, 10, 17, 10, 30, 00, Rational(4,24))}"
      # unaffected days
      examples << "Boston|1 hour|1 hour|5:24 AM|#{DateTime.new(2011, 10, 16, 10, 30, 00, Rational(4,24))}"
      examples << "Boston|1 hour|1 hour|5:24 AM|#{DateTime.new(2011, 10, 21, 10, 30, 00, Rational(4,24))}"

      examples.each do |ex|
        t1 = Time.parse(ex.split("|")[3])
        t2 = Time.parse(@filter.modify(ex).split("|")[3])
        t1.should == t2
      end
    end
  end
  
  context "DiscardFutureAndPastReports filter" do

    before(:each) do
      @filter = WaitTimeUtils::WaitTimeFilters::DiscardFutureAndPastReports.new
    end
    
    it "discards reports from the past" do
      @filter.discard?(too_far_past_line).should be_true
     end
    
    it "discards reports from the future" do
      @filter.discard?(too_far_future_line).should be_true
     end
    
    it "keeps reports that aren't too far in the past" do
      @filter.discard?(not_too_far_past_line).should be_false
      @filter.discard?(not_too_far_past_line_utc).should be_false
    end
    
    it "keeps reports that aren't too far in the future" do
      @filter.discard?(not_too_far_future_line).should be_false
      @filter.discard?(not_too_far_future_line_utc).should be_false
    end
  end
  
  context "WaitTimeFixer" do
       
    before(:each) do
      @fixer = WaitTimeUtils::WaitTimeFixer.new
    end
    
    it "should turn non-UTC times into UTC" do
      @fixer.parse_line(good_line).should == good_line_utc
      @fixer.parse_line(good_line_elsewhere).should == good_line_elsewhere_utc
      @fixer.parse_line(good_line_earlier).should == good_line_earlier_utc
      @fixer.parse_line(good_line_later).should == good_line_later_utc
    end
    
    it "should not affect times that are already UTC" do
      @fixer.parse_line(good_line_utc).should == good_line_utc
      @fixer.parse_line(good_line_elsewhere_utc).should == good_line_elsewhere_utc
      @fixer.parse_line(good_line_earlier_utc).should == good_line_earlier_utc
      @fixer.parse_line(good_line_later_utc).should == good_line_later_utc
    end
    
    it "should discard malformed lines" do
      @fixer.parse_line("obviously bad").should be_nil
    end
    
    it "should discard lines with bad status" do
      @fixer.parse_line(tech_difficulties_line).should be_nil
      @fixer.parse_line(closed_line).should be_nil
    end
    
    it "should fix times from the bad October 2011 period" do
      # Try a real October time
      oct_orig = "Worcester|No wait time|6 minutes, 44 seconds|2:57 AM|Mon Oct 24 08:10:09 -0400 2011"
      oct_fixed = "Worcester|No wait time|6 minutes, 44 seconds|2011-10-24T11:57:00+00:00|2011-10-24T12:10:09+00:00"
      @fixer.parse_line(oct_orig).should == oct_fixed

      # Try another real October time
      oct_orig = "Brockton|No wait time|No wait time|3:19 AM|Wed Oct 19 08:32:15 -0400 2011"
      oct_fixed = "Brockton|No wait time|No wait time|2011-10-19T12:19:00+00:00|2011-10-19T12:32:15+00:00"
      @fixer.parse_line(oct_orig).should == oct_fixed
    end
  end
end