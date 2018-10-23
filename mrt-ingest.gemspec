$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "mrt-ingest"
  s.version     = "0.0.4"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mark Reyes", "David Moles"]
  s.email       = ["mark.reyes@ucop.edu", "david.moles@ucop.edu"]
  s.homepage    = "https://github.com/CDLUC3/mrt-ingest-ruby"
  s.summary     = %q{A client for Merritt ingest.}
  s.description = %q{A client for the Merritt ingest system. More details available from https://github.com/CDLUC3/mrt-doc/wiki}
  s.license     = "BSD-3-Clause"

  s.add_dependency "json", "~> 2.0"
  s.add_dependency "rest-client", "~> 1.6", ">=1.6.0"

  s.add_development_dependency "bundler"
  s.add_development_dependency "checkm", "0.0.6"
  # TODO: put this back in once there's a 2.4-compatible release
  # s.add_development_dependency "fakeweb"
  s.add_development_dependency "mocha"
  s.add_development_dependency "rake"
  s.add_development_dependency "shoulda"
  s.add_development_dependency "test-unit"

  s.files         = `git ls-files -z`.split("\x0")
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]
end
