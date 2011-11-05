Dir[File.dirname(__FILE__) + "/extensions/*.rb"].each { |f| require f; puts "loaded #{f}" }
