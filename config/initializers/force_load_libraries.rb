Dir.glob("#{Rails.root}/extras/force_load/*.rb").each { |f| require f }
