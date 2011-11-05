class FetchWaitTimesJob
    def perform
        File.open("/tmp/fetcher", "a+") { |f| f.puts "Job's done!" }
    end
end
