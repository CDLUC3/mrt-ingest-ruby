# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mrt_ingest/version"

Gem::Specification.new do |s|
  s.name        = "mrt-ingest"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Erik Hetzner"]
  s.email       = ["erik.hetzner@ucop.edu"]
  s.homepage    = ""
  s.summary     = %q{A client for Merritt ingest.}

  s.add_dependency "json", ">=1.5.0"
  s.add_dependency "rest-client", ">=1.6.0"

  s.rubyforge_project = "mrt-ingest"

  s.files         = `hg locate`.split("\n")
  s.test_files    = `hg locate --include '{spec,features}'`.split("\n")
  s.executables   = `hg locate --include bin`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
