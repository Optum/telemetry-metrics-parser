# frozen_string_literal: true

require_relative 'lib/telemetry/metrics/parser/version'

Gem::Specification.new do |spec|
  spec.name = 'telemetry-metrics-parser'
  spec.version       = Telemetry::Metrics::Parser::VERSION
  spec.authors       = ['Esity']
  spec.email         = %w[matthewdiverson@gmail.com ruby@optum.com]

  spec.summary       = 'Parses common line formats for InfluxDB Line Protocol and turns it into a ruby hash'
  spec.description   = 'A metrics line parser gem for things like influxdb line protocol'
  spec.homepage      = 'https://github.com/Optum/telemetry-metrics-parser'
  spec.license       = 'Apache-2.0'
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.5'
  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files        = spec.files.select { |p| p =~ %r{^test/.*_test.rb} }
  spec.extra_rdoc_files  = %w[README.md LICENSE CHANGELOG.md]
  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/Optum/telemetry-metrics-parser/issues',
    'changelog_uri' => 'https://github.com/Optum/telemetry-metrics-parser/src/main/CHANGELOG.md',
    'documentation_uri' => 'https://github.com/Optum/telemetry-metrics-parser',
    'homepage_uri' => 'https://github.com/Optum/telemetry-metrics-parser',
    'source_code_uri' => 'https://github.com/Optum/telemetry-metrics-parser',
    'wiki_uri' => 'https://github.com/Optum/telemetry-metrics-parser/wiki'
  }
end
