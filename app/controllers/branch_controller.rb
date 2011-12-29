class BranchController < ApplicationController
  def view
    @branch = Branch.find_by_name(params[:name])
  end
  
  def test_graph
    require 'gruff'
    @branch = Branch.find_by_name(params[:name])
    
    g = Gruff::Line.new
    g.title = "#{@branch.human_name} Wait Times, October 2011"
    #registration_times = @branch.wait_times_for_month(10).where(:kind => :registration).map {|wt| wt.duration}
    times = @branch.wait_times.where("reported_at >= ? AND reported_at <= ?", 
      Date.parse("2011-10-01"), Date.parse("2011-10-31"))
    registration = times.inject([]) { |a, t| t.kind == 'registration' ? a << t.duration : a }
    licensing = times.inject([]) { |a, t| t.kind == 'licensing' ? a << t.duration : a }
    #-- categorized_times = times.inject(Hash.new {|h, k| h[k] = Array.new}) { |memo, t| memo[t.kind] << t.duration; memo }
    #registration_times = @branch.wait_times.where("reported_at >= ? AND reported_at <= ? AND kind = 'registration'", 
    #  Date.parse("2011-10-01"), Date.parse("2011-10-31")).map {|wt| wt.duration}
    g.data("Registration", registration)
    g.data("Licensing", licensing)
    #g.data("Reg.Times", registration_times)
    filename = "registration.png"
    g.write(filename)
    send_file filename, :type => 'image/png', :disposition => 'inline'
  end

  def graph
    require 'gruff'
    @branch = Branch.find_by_name(params[:name])
    
    licensing, registration = @branch.wait_times.where("reported_at >= ? AND reported_at <= ?", 
      Date.from_param(params[:start_date]),
      Date.from_param(params[:end_date]))

    g = Gruff::Line.new
    g.title = "#{@branch.human_name} Wait Times (requested date)"
    g.data("Registration", registration)
    g.data("Licensing", licensing)
    filename = "registration.png"
    g.write(filename)
    send_file filename, :type => 'image/png', :disposition => 'inline'
  end
end
