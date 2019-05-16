# ------------------------------------------------------------
# SimpleCov setup

if ENV['COVERAGE']
  require 'simplecov'
  require 'simplecov-console'

  SimpleCov.command_name 'spec:lib'

  SimpleCov.minimum_coverage 100
  SimpleCov.start do
    add_filter '/spec/'
    SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::Console,
    ]
  end
end

# ------------------------------------------------------------
# Rspec configuration

require 'webmock/rspec'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.mock_with :rspec
  hostname_lower = Socket.gethostname.downcase # https://github.com/bblimke/webmock/issues/819
  config.before(:each) { WebMock.disable_net_connect!(allow: hostname_lower) }
  config.after(:each) { WebMock.allow_net_connect! }
end

# ------------------------------------------------------------
# Code under test

require 'mrt/ingest'
