require 'spec_helper'
require 'telemetry/metrics/parser'

RSpec.describe Telemetry::Metrics::Parser do
  it 'has a version number' do
    expect(Telemetry::Metrics::Parser).not_to be nil
  end
end
