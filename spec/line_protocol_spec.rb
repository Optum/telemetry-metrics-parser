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

  it 'can to_line_protocol' do
    expect(
      described_class.to_line_protocol(
        measurement: 'test',
        tags: { foo: 'bar' },
        fields: { hello: 'world' },
        timestamp: 1_000_000_000
      )
    ).to eq 'test,foo=bar hello=world 1000000000'

    expect(
      described_class.to_line_protocol(
        measurement: 'test',
        tags: { foo: 'bar', tag: 'test' },
        fields: { hello: 4444, field: '120202' },
        timestamp: 1_000_000_000
      )
    ).to eq 'test,foo=bar,tag=test hello=4444,field=120202 1000000000'
  end

  it 'can hash_to_line' do
    expect(described_class.hash_to_line({ foo: 'bar', test: 'baz' })).to eq 'foo=bar,test=baz'
    expect(described_class.hash_to_line({ foo: 'bar' })).to eq 'foo=bar'
    expect(described_class.hash_to_line({ foo: 'bar', test: 123 })).to eq 'foo=bar,test=123'
  end
end
