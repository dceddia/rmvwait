class WaitTimeFixtureGenerator
  def self.decode_duration(d)
    day = d / 100; d -= (day * 100)
    branch_id = d / 10; d -= (branch_id * 10)
    hour = d
    [branch_id, day, hour]
  end
  
  def self.make_duration(branch_id, day, hour)
    (day * 100) + (branch_id * 10) + hour
  end
  
  def self.generate
    wait_times_file = File.open("#{Rails.root.to_s}/spec/fixtures/wait_times.yml", "w")
    branch_file = "#{Rails.root.to_s}/spec/fixtures/branches.yml"
    branches = YAML::load(File.open(branch_file))
    branch_ids = branches.inject({}) {|result, (k,v)| result[v["id"]] = v["name"]; result }
    month = 12
    days = 5..9
    year = 2011
    wt_id = 1
    kinds = %W{licensing registration}
    hours = [Time.parse("09:00"), Time.parse("11:00"), Time.parse("12:00"), Time.parse("14:00"), Time.parse("16:30")]
    branch_ids.keys.sort.each do |id|
      days.each_with_index do |day, day_num|
        kinds.each do |kind|
          hours.each_with_index do |t, hour_num|
            reported_at = DateTime.new(year, month, day, t.hour, t.min, t.sec, t.zone)
            duration = make_duration(id, day_num + 1, hour_num + 1)
            wait_times_file.puts ("%04d%02d%02d_#{id}_#{day_num}_#{hour_num}_#{kind}:" % [year, month, day])
            wait_times_file.puts "  id: #{wt_id}"
            wait_times_file.puts "  branch_id: #{id}"
            wait_times_file.puts "  kind: #{kind}"
            wait_times_file.puts "  reported_at: #{reported_at.utc}"
            wait_times_file.puts "  duration: #{duration}"
            wt_id += 1
          end
        end
      end
    end
  end
end

desc "Generate fixtures (branches and wait times)"
task :generate_fixtures do |t, args|
  WaitTimeFixtureGenerator.generate
end