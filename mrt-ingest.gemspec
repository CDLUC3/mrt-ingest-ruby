$LOAD_PATH.push File.expand_path('lib', __dir__)

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 2.4.0'
  s.name        = 'mrt-ingest'
  s.version     = '0.0.5'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Mark Reyes', 'David Moles']
  s.email       = ['mark.reyes@ucop.edu', 'david.moles@ucop.edu']
  s.homepage    = 'https://github.com/CDLUC3/mrt-ingest-ruby'
  s.summary     = 'A client for Merritt ingest.'
  s.description = 'A client for the Merritt ingest system. More details available from https://github.com/CDLUC3/mrt-doc/wiki'
  s.license     = 'BSD-3-Clause'

  s.add_dependency 'json', '~> 2.0'
  s.add_dependency 'rest-client', '~> 2.0'

  s.add_development_dependency 'bundler', '>= 2.2.10'
  s.add_development_dependency 'checkm', '0.0.6'
  s.add_development_dependency 'mocha', '~> 1.7'
  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'rspec', '~> 3.8'
  s.add_development_dependency 'rubocop', '~> 0.68'
  s.add_development_dependency 'shoulda', '~> 3.6'
  s.add_development_dependency 'simplecov', '~> 0.16'
  s.add_development_dependency 'simplecov-console', '~> 0.4'
  s.add_development_dependency 'webmock', '~> 3.5'

  s.files         = `git ls-files -z`.split("\x0")
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']
end
