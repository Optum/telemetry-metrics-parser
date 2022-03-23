require 'spec_helper'
require 'telemetry/metrics/parser/line_protocol'

RSpec.describe Telemetry::Metrics::Parser::LineProtocol do
  it 'can validate the measurement' do
    expect(described_class.measurement_valid?('foobar')).to eq true
    expect(described_class.measurement_valid?('FooBar')).to eq true
    expect(described_class.measurement_valid?('foo-bar')).to eq true
    expect(described_class.measurement_valid?('foo-bar_test')).to eq true
    expect(described_class.measurement_valid?('foo.test-bar_again')).to eq true
  end

  it 'can validate tags' do
    expect(described_class.tag_is_valid?('foobar', 'testing')).to eq true
    expect(described_class.tag_is_valid?('foo_bar', 'testing')).to eq true
    expect(described_class.tag_is_valid?('foo-bar', 'testing')).to eq true
    expect(described_class.tag_is_valid?('foo.bar', 'testing')).to eq true
    expect(described_class.tag_is_valid?('test', 'foo.bar')).to eq true
    expect(described_class.tag_is_valid?('test', 'foo-bar')).to eq true
    expect(described_class.tag_is_valid?('test', 'foo_bar')).to eq true
    expect(described_class.tag_is_valid?('test world', 'foo_bar')).to eq false
    expect(described_class.tag_is_valid?('test&world', 'foo_bar')).to eq false
    expect(described_class.tag_is_valid?('test', 'foo%bar')).to eq false
  end

  it 'can validate fields' do
    expect(described_class.field_is_number?(1)).to eq true
    expect(described_class.field_is_number?(0.11111)).to eq true
    expect(described_class.field_is_number?('foobar')).to eq false
    expect(described_class.field_is_number?('1i')).to eq true
    expect(described_class.field_is_number?('1f')).to eq true
    expect(described_class.field_is_number?('1.1f')).to eq true
  end

  it 'can validate the line is current' do
    expect(described_class.line_is_current?(1_465_839_830_100_400_200)).to eq false
    expect(described_class.line_is_current?(2_665_839_830_100_400_200)).to eq true
    expect(described_class.line_is_current?('11111')).to eq false
  end

  it 'can verify a node_group tag exists' do
    expect(described_class.node_group_tag?({ foo: 'bar' })).to eq false
    expect(described_class.node_group_tag?({ influxdb_node_group: 'bar' })).to eq true
  end

  it 'can verify a database_tag exists' do
    expect(described_class.database_tag?({ foo: 'bar' })).to eq false
    expect(described_class.database_tag?({ influxdb_database: 'bar' })).to eq true
  end

  it 'can validate a line' do
    expect(described_class.line_is_valid?('weather,location=us-midwest temperature=82 1465839830100400200')).to be_a String
    expect(described_class.line_is_valid?('weather,location=us-midwest temperature=82 2465839830100400200')).to be_a String
    expect(described_class.line_is_valid?('weather,location=us-midwest,influxdb_database=foo temperature=82 2465839830100400200')).to be_a String
    expect(described_class.line_is_valid?('weather,location=us-midwest,influxdb_database=foo,influxdb_node_group=foo temperature=82 2465839830100400200')).to be_truthy
    expect(described_class.line_is_valid?('weather,location=us-midwest,influxdb_database=foo,influxdb_node_group=foo temperature=82,field=aaa 2465839830100400200')).to be_a String
    expect(described_class.line_is_valid?('weather,locat%ion=us-midw%est,influxdb_database=foo,influxdb_node_group=foo temperature=82 2465839830100400200')).to be_a String
  end
end
