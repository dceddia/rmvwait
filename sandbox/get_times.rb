#!/usr/bin/ruby

require 'open-uri'
require 'cgi'

def parseWaitTimeInfo(info)
  info.split("|")
end

def isWaitInfoValid(info)
    info.split("|").length == 3
end

#WaitTimesURL = "http://www.massdot.state.ma.us/rmv/BranchInfo/GetWaitTimes.aspx"
WaitTimesURL = "http://www.massdot.state.ma.us/DesktopModules/BranchMapDNN/GetWaitTimes.aspx"

# read all branch names
branches = File.readlines('branches.txt')

lastTimes = {}
branches.each do |branch| 
    lastTimes[branch] = {}
    lastTimes[branch][:licensing] = nil;
    lastTimes[branch][:registration] = nil;
end

while true do
    puts "Fetching wait times at #{Time.now}"
    # get wait time info for each branch
    num = 0
    branches.each do |branch|
        begin
            branch.strip!
            cacheBuster = (Time.now.to_f * 1000).to_i.to_s
            queryUrl = WaitTimesURL + '?Town=' + CGI::escape(branch) + '&' + CGI::escape(cacheBuster)
            waitInfo = open(queryUrl).read
            next unless isWaitInfoValid(waitInfo)
            licensing, registration, lastUpdated = parseWaitTimeInfo( waitInfo )
            sleep(rand + 0.5)
            next if licensing == "Closed" || registration == "Closed"
            next if lastTimes[branch][:licensing] == licensing and lastTimes[branch][:registration] == registration
            line = "#{branch}|#{licensing}|#{registration}|#{lastUpdated}|#{Time.now}"
            lastTimes[branch][:licensing] = licensing
            lastTimes[branch][:registration] = registration
            #puts "branch: #{branch}"
            #puts "  licensing: #{licensing}"
            #puts "  registration: #{registration}"
            #puts "  last updated: #{lastUpdated}"
            File.open("wait_times.txt", "a+") do |f|
                f.puts line
            end
            num += 1
        rescue Timeout::Error => e
            puts "Request timed out for #{branch} - #{e.message}"
        rescue Exception => e
            puts "Failed to update #{branch} - #{e.message}"
        end
    end
    puts "Done, got #{num} times."
    sleep 600 # 10 minutes
end
