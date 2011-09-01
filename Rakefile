require 'rake/testtask'

require 'bundler'
include Rake::DSL
Bundler::GemHelper.install_tasks

task :default => [:test]
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/**/test_*.rb'
  t.verbose = true
end
