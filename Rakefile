# coding: utf-8

require "bundler/gem_tasks"

require 'logger'

Log = Logger.new(STDOUT)

task :default => :spec

# clear
desc 'Delete working files'
task :clean do
  system 'rm -f README.html'
  system 'rm -fr doc/*'
  system 'rm -fr coverage'
  system 'rm -fr log/*'
  system 'rm -fr tmp/metric_fu'
  system 'rm -fr tmp/churn'
  Dir.glob('**/*~').each { |f| FileUtils.rm f }
  Dir.glob('**/work-diff').each { |f| FileUtils.rm_rf f }
end

# checkstyle
desc 'checkstyle using rubocop.'
task :checkstyle do
  system 'rubocop lib/*.rb'
end

# metrics
require 'metric_fu'

# spec/coverage
require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end
