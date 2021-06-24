require 'spec_helper'
require 'telemetry/metrics/parser/line_protocol'

RSpec.describe Telemetry::Metrics::Parser::LineProtocol do
  it 'can parse influxdb line protocol' do
    expect(described_class.parse('weather,location=us-midwest temperature=82 1465839830100400200')).to be_a Hash
    expect(described_class.parse('weather,location=us-midwest temperature=82 1465839830100400200')[:timestamp]).to eq 1_465_839_830_100_400_200
    expect(described_class.parse('weather,location=us-midwest temperature=82 1465839830100400200')[:measurement]).to eq 'weather'
    expect(described_class.parse('weather,location=us-midwest temperature=82 1465839830100400200')[:fields]).to eq(temperature: 82)
    expect(described_class.parse('weather,location=us-midwest temperature=82 1465839830100400200')[:tags]).to eq({ location: 'us-midwest' })
  end

  it 'can parse influxdb line protocol with shell words' do
    expect(described_class.parse('weather,location=us-midwest temperature=82 1465839830100400200', use_shellwords: true)).to be_a Hash
  end

  it 'can run split_string_to_hash' do
    expect(described_class.split_string_to_hash('location=us-midwest')).to eq({ location: 'us-midwest' })
    expect(described_class.split_string_to_hash('measurement,location=us-midwest')).to eq({ location: 'us-midwest' })
    expect(
      described_class.split_string_to_hash('measurement,location=us-midwest,test=foo')
    ).to eq({ location: 'us-midwest', test: 'foo' })

    expect(
      described_class.split_string_to_hash('location=us-midwest,key=this is a  space')
    ).to eq({ location: 'us-midwest', key: 'this is a  space' })
  end

  it 'can get the measurement' do
    expect(described_class.get_measurement('test,location=foo')).to eq 'test'
    expect(described_class.get_measurement('location=foo,test=baz')).to be_nil
  end
end
