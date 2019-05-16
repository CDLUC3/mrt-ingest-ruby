Dir.glob(File.expand_path('ingest/*.rb', __dir__)).sort.each(&method(:require))
