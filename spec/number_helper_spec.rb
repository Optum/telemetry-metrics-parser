require 'spec_helper'
require 'telemetry/number_helper'

RSpec.describe Telemetry::NumberHelper do
  it 'can detect floats' do
    expect(described_class.float?('a')).to be_falsey
    expect(described_class.float?('111')).to be_falsey
    expect(described_class.float?('-1234')).to be_falsey
    expect(described_class.float?('1.1111')).to be_truthy
    expect(described_class.float?('-1.1111')).to be_truthy
  end

  it 'can detect integers' do
    expect(described_class.integer?('a')).to be_falsey
    expect(described_class.integer?('1')).to be_truthy
    expect(described_class.integer?('-1234')).to be_truthy
    expect(described_class.integer?('1.1111')).to be_falsey
    expect(described_class.integer?('-1.1111')).to be_falsey
  end

  it 'can detect numbers' do
    expect(described_class.number?('1')).to be_truthy
    expect(described_class.number?('111')).to be_truthy
    expect(described_class.number?('-234')).to be_truthy
    expect(described_class.number?('123.7777')).to be_truthy
    expect(described_class.number?('-123.7777')).to be_truthy

    expect(described_class.number?('-123.7a777')).to be_falsey
    expect(described_class.number?('this is a value')).to be_falsey
    expect(described_class.number?('a value 12929')).to be_falsey
    expect(described_class.number?('1a')).to be_falsey
  end

  it 'can convert_to_number' do
    expect(described_class.convert_to_number(1)).to eq 1
    expect(described_class.convert_to_number('1')).to eq 1
    expect(described_class.convert_to_number('-1')).to eq(-1)
    expect(described_class.convert_to_number('1.22')).to eq 1.22
    expect(described_class.convert_to_number(1.22)).to eq 1.22
    expect(described_class.convert_to_number('aaa')).to eq 'aaa'
    expect(described_class.convert_to_number('1aaa')).to eq '1aaa'
    expect(described_class.convert_to_number('aaa2')).to eq 'aaa2'
  end
end
