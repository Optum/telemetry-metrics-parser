require 'spec_helper'
require 'telemetry/metrics/parser'

RSpec.describe Telemetry::Metrics::Parser do
  it 'has a version number' do
    expect(Telemetry::Metrics::Parser).not_to be nil
  end

  it 'can route to_line_protocol parser' do
    expect(described_class.from_line_protocol('weather,location=us-midwest temperature=82 1465839830100400200')).to be_a Hash
  end

  it 'can from_line_protocol' do
    expect(
      described_class.to_line_protocol(
        measurement: 'test',
        tags: { foo: 'bar' },
        fields: { hello: 'world' },
        timestamp: 1_000_000_000
      )
    ).to eq 'test,foo=bar hello=world 1000000000'
  end
end
