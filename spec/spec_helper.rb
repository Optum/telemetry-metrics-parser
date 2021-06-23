begin
  require 'simplecov'
  SimpleCov.start
  SimpleCov.use_merging(true)
  SimpleCov.minimum_coverage 95
rescue LoadError
  puts 'Failed to load file for coverage reports, continuing without it'
end

require 'bundler/setup'
require 'telemetry/metrics/parser'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end
