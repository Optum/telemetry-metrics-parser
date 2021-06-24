require 'spec_helper'
require 'telemetry/metrics/parser'

RSpec.describe Telemetry::Metrics::Parser do
  it 'has a version number' do
    expect(Telemetry::Metrics::Parser).not_to be nil
  end

  it 'can route to line_protocol parser' do
    expect(described_class.line_protocol('weather,location=us-midwest temperature=82 1465839830100400200')).to be_a Hash
  end
end
