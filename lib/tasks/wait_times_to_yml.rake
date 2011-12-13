#!/usr/bin/ruby

def output_record(month, day, id, kind, branch_id, duration)
  month_name = Date::ABBR_MONTHNAMES[month] 
  puts "#{month_name}#{day}_#{id}_#{kind}:"
  puts "  id: #{id}"
  puts "  kind: '#{kind}'"
  puts "  branch_id: #{branch_id}"
  puts "  duration: #{duration}"
end

def parse_record_line(line)
  branch_name, licensing_wait, registration_wait, reported_time, retrieved_at = line.split('|')
  licensing_duration = RMVDuration.parse(licensing_wait)
  registration_duration = RMVDuration.parse(registration_wait)
  reported_time = Time.parse(reported_time)
  reported_at = Time.parse(retrieved_at).change(:hour => reported_time.hour, 
                                                :min => reported_time.min)
  return licensing_duration, registration_duration, reported_at
end

desc "Create YAML from wait times"
task :times_to_yaml, [:filename, :branch_id, :first_id] => [:environment] do |t, args|

  if args[:filename] == nil || args[:branch_id] == nil
    puts "Usage: rake times_to_yaml['wait_times.txt', branch_id, first_id]" 
    exit
  end

  times = File.readlines(args[:filename])
  branch_id = args[:branch_id].to_i
  
  id = (args[:first_id] || 1).to_i
  times.each do |t|
    licensing_duration, registration_duration, reported_at = parse_record_line(t)
    output_record(reported_at.month, reported_at.day, id, 'licensing', branch_id, licensing_duration)
    id += 1
    output_record(reported_at.month, reported_at.day, id, 'registration', branch_id, registration_duration)
    id += 1
  end
end
