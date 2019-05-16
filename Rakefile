# -*- ruby -*-
require 'rake/testtask'
require 'rdoc/task'

require 'bundler'

Bundler::GemHelper.install_tasks

task default: [:test]
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/**/test_*.rb'
  t.verbose = true
end

RDoc::Task.new do |rd|
  rd.title = 'Merritt Ingest Client'

  rd.options += ['-f', 'darkfish']
end
