# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "mrt-ingest"
  s.version     = "0.0.3"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Erik Hetzner"]
  s.email       = ["mark.reyes@ucop.edu"]
  s.homepage    = "https://github.com/CDLUC3/mrt-ingest-ruby"
  s.summary     = %q{A client for Merritt ingest.}
  s.description = %q{A client for the Merritt ingest system. More details available from http://wiki.ucop.edu/display/curation.}

  s.add_dependency "json", ">=1.5.0"
  s.add_dependency "rest-client", ">=1.6.0"

  s.rubyforge_project = "mrt-ingest"

  s.files         = `hg locate`.split("\n")
  s.test_files    = `hg locate --include '{spec,features}'`.split("\n")
  s.executables   = `hg locate --include bin`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
