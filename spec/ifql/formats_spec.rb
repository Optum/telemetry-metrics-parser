require 'spec_helper'
require 'telemetry/ifql/formats'

RSpec.describe Telemetry::IFQL::Formats do
  it 'can run measurement_error' do
    expect(Telemetry::IFQL::Formats.measurement_error('error message', status: 501)).to be_a Hash
    results = Telemetry::IFQL::Formats.measurement_error('error message', status: 501)
    expect(results[:result][:status]).to eq 501
    expect(results[:result][:error]).to eq 'error message'
  end
  it 'has a default measurement' do
    expect(Telemetry::IFQL::Formats::MEASUREMENT).to be_a Hash
  end

  it 'has field keys' do
    expect(Telemetry::IFQL::Formats::FIELD_KEYS).to be_a Hash
  end

  it 'has database' do
    expect(Telemetry::IFQL::Formats::DATABASE).to be_a Hash
  end

  it 'has retention policies' do
    expect(Telemetry::IFQL::Formats::RETENTION_POLCIES).to be_a Hash
  end

  it 'has tag values' do
    expect(Telemetry::IFQL::Formats::TAG_VALUES).to be_a Hash
  end
end
