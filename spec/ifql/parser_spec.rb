require 'spec_helper'
require 'telemetry/ifql/parser'

RSpec.describe Telemetry::IFQL::Parser do
  it 'can initialize' do
    expect { Telemetry::IFQL::Parser.new('') }.not_to raise_exception
  end

  it 'can replace ms style queries with seconds' do
    expect do
      Telemetry::IFQL::Parser.new('SELECT mean("blocked") FROM "processes" WHERE (time >= 1624971769069ms and time <= 1624972400238ms GROUP BY time(10s), "host", "dc" fill(null)')
    end.not_to raise_exception

    results = Telemetry::IFQL::Parser.new('SELECT mean("blocked") FROM "processes" WHERE (time >= 1624971769069ms and time <= 1624972400238ms GROUP BY time(10s), "host", "dc" fill(null)')
    expect(results.conditions).to include('time >= 1624971770')
    expect(results.conditions).to include('time <= 1624972400')
  end

  it 'can get query type' do
    expect(Telemetry::IFQL::Parser.new('SHOW MEASUREMENTS').query_type).to eq :measurement
    expect(Telemetry::IFQL::Parser.new('SHOW MEASUREMENTS ON CPU').query_type).to eq :measurement
    expect(Telemetry::IFQL::Parser.new('SHOW DATABASES').query_type).to eq :database
    expect(Telemetry::IFQL::Parser.new('SHOW RETENTION POLICIES').query_type).to eq :rp
    expect(Telemetry::IFQL::Parser.new('SHOW RETENTION POLICIES ON \'cpu\'').query_type).to eq :rp
    expect(Telemetry::IFQL::Parser.new('SHOW FIELD KEYS').query_type).to eq :field_key
    expect(Telemetry::IFQL::Parser.new('SHOW FIELD KEYS ON cpu.autogen').query_type).to eq :field_key
    expect(Telemetry::IFQL::Parser.new('SHOW TAG KEYS').query_type).to eq :tag_key
    expect(Telemetry::IFQL::Parser.new('SHOW TAG KEYS FROM test.bar').query_type).to eq :tag_key
    expect(Telemetry::IFQL::Parser.new('SHOW TAG VALUES').query_type).to eq :tag_value
    expect(Telemetry::IFQL::Parser.new('SHOW TAG VALUES WHERE KEY = "host"').query_type).to eq :tag_value
    expect(Telemetry::IFQL::Parser.new('SHOW SERIES').query_type).to eq :series
    expect(Telemetry::IFQL::Parser.new('SHOW SERIES ON cpu.autogen').query_type).to eq :series
    expect(Telemetry::IFQL::Parser.new('this does not match anything').query_type).to eq :data
    expect(Telemetry::IFQL::Parser.new('').query_type).to eq :data
  end

  it 'can get the limit when it exists' do
    expect(Telemetry::IFQL::Parser.new('SELECT non_negative_derivative(mean(out), 1s) FROM telegraf.autogen.swap WHERE (host = \'foobar\') AND time >= now() - 1h GROUP BY time(1m), host LIMIT 10000').limit?).to eq true
    expect(Telemetry::IFQL::Parser.new('SELECT non_negative_derivative(mean(out), 1s) FROM telegraf.autogen.swap WHERE (host = \'foobar\') AND time >= now() - 1h GROUP BY time(1m), host LIMIT 10000').limit).to eq 10_000
    expect(Telemetry::IFQL::Parser.new('this is a test limit 10000').limit).to eq 10_000
    expect(Telemetry::IFQL::Parser.new('this is a test limit 10000').limit?).to eq true
  end

  it 'can handle limit exceptions' do
    expect(Telemetry::IFQL::Parser.new('limit 5000').limit).to eq 5000
    expect(Telemetry::IFQL::Parser.new('limit aa222').limit).to be_nil
  end

  it 'can handle when there is no limit' do
    expect(Telemetry::IFQL::Parser.new('SELECT non_negative_derivative(mean(out), 1s) FROM telegraf.autogen.swap WHERE (host = \'foobar\') AND time >= now() - 1h GROUP BY time(1m), host').limit?).to eq false
    expect(Telemetry::IFQL::Parser.new('SELECT non_negative_derivative(mean(out), 1s) FROM telegraf.autogen.swap WHERE (host = \'foobar\') AND time >= now() - 1h GROUP BY time(1m), host').limit).to eq nil
  end

  it 'can initialize with a database' do
    expect { Telemetry::IFQL::Parser.new('', db: 'telegraf') }.not_to raise_exception
    expect(Telemetry::IFQL::Parser.new('', db: 'telegraf').database).to eq 'telegraf'
    expect(Telemetry::IFQL::Parser.new('', db: 'foobar').database).to eq 'foobar'
  end

  it 'can get measurement' do
    expect(Telemetry::IFQL::Parser.new('SHOW TAG VALUES FROM cpu WITH KEY = "dc"').measurement).to eq 'cpu'
    expect(Telemetry::IFQL::Parser.new('SHOW TAG VALUES FROM cpu').measurement).to eq 'cpu'
    expect(Telemetry::IFQL::Parser.new('SELECT last(n_cpus) FROM telegraf.autogen.system WHERE (host = \'foobar\') AND time >= now() - 1h GROUP BY time(1m)').measurement).to eq 'system'
    expect(Telemetry::IFQL::Parser.new('SELECT non_negative_derivative(mean(out), 1s) FROM telegraf.autogen.swap WHERE (host = \'foobar\') AND time >= now() - 1h GROUP BY time(1m), host').measurement).to eq 'swap'
    expect(Telemetry::IFQL::Parser.new('SHOW TAG VALUES ON telegraf WITH KEY =~ /^(askID|automation|dc|env|host|os|platform|portfolio|project|role|service|type|zone)$/ WHERE (_name = \'mem\') AND ((host =~ /^foo$/ AND time > now() - 1h) AND (_tagKey =~ /^(askID|automation|dc|env|host|os|platform|portfolio|project|role|service|type|zone)$/))').measurement).to eq nil
  end

  it 'can get conditions' do
    expect(Telemetry::IFQL::Parser.new('SHOW TAG VALUES FROM cpu WITH KEY = "dc"').conditions).to eq []
    query = 'SHOW TAG VALUES FROM cpu WITH KEY = "dc" WHERE test = "foo" AND foo = "bar"'

    expect(Telemetry::IFQL::Parser.new(query).conditions).to be_a Array
    expect(Telemetry::IFQL::Parser.new(query).conditions.count).to eq 2
    expect(Telemetry::IFQL::Parser.new(query).conditions.first).to be_a String
    expect(Telemetry::IFQL::Parser.new(query).conditions.first).to eq 'test = "foo"'
    expect(Telemetry::IFQL::Parser.new(query).conditions.last).to eq 'foo = "bar"'

    query = "SELECT non_negative_difference(max(read_time)) FROM telegraf.autogen.diskio WHERE (host = 'foobar') AND time >= now() - 1h GROUP BY time(1m), host"
    conditions = Telemetry::IFQL::Parser.new(query).conditions
    expect(conditions).to be_a Array
    expect(conditions.count).to eq 2
    expect(conditions.first).to eq("host = 'foobar'")
    expect(conditions.last).to eq 'time >= now() - 1h'
  end

  it 'can rescue exceptions within conditions' do
    parser = described_class.new('SHOW TAG VALUES FROM cpu WITH KEY = "dc"')
    expect(parser.conditions).to eq []

    parser = described_class.new('where')
    expect(parser.conditions).to eq []
  end

  it 'can get group_by' do
    query = "SELECT non_negative_difference(max(read_time)) FROM telegraf.autogen.diskio WHERE (host = 'foobar') AND time >= now() - 1h GROUP BY time(1m), host"
    group = Telemetry::IFQL::Parser.new(query).group_by
    expect(group).to be_a Array
    expect(group.count).to eq 2
    expect(group.first).to eq 'time(1m)'
    expect(group.last).to eq 'host'
  end

  it 'can group_by_time?' do
    query = "SELECT non_negative_difference(max(read_time)) FROM telegraf.autogen.diskio WHERE (host = 'foobar') AND time >= now() - 1h GROUP BY time(1m), host"
    expect(Telemetry::IFQL::Parser.new(query).group_by_time?).to eq true
    expect(Telemetry::IFQL::Parser.new('SHOW TAG VALUES FROM cpu WITH KEY = "dc"').group_by_time?).to eq false
  end

  it 'can check for time filter' do
    query = "SELECT non_negative_difference(max(read_time)) FROM telegraf.autogen.diskio WHERE (host = 'foobar') AND time >= now() - 1h GROUP BY time(1m), host"
    parser = Telemetry::IFQL::Parser.new(query)
    expect(parser.time_filter?).to eq true

    query = 'SHOW TAG VALUES FROM cpu WITH KEY = "dc" WHERE test = "foo" AND foo = "bar"'
    parser = Telemetry::IFQL::Parser.new(query)
    expect(parser.time_filter?).to eq false
  end

  it 'can support grafana style syntax' do
    query = 'SELECT mean("usage_steal") FROM "cpu" WHERE ("host" =~ /^$host$/) AND time >= now() - 1h GROUP BY time(10s) fill(null)'
    expect(Telemetry::IFQL::Parser.new(query).group_by_time?).to eq true
    expect(Telemetry::IFQL::Parser.new(query).measurement).to eq 'cpu'

    query = 'SELECT mean("relocating_shards") AS "Relocating", mean("unassigned_shards") AS "Unassigned", mean("active_shards") AS "Active", mean("initializing_shards") AS "Initializing" FROM "elasticsearch_cluster_health" WHERE ("portfolio" = \'reliability_engineering\' AND "env" = \'production\') AND $timeFilter GROUP BY time($__interval) fill(null)'
    expect(Telemetry::IFQL::Parser.new(query).measurement).to eq 'elasticsearch_cluster_health'

    query = 'SELECT mean("relocating_shards") AS "Relocating", mean("unassigned_shards") AS "Unassigned", mean("active_shards") AS "Active", mean("initializing_shards") AS "Initializing" FROM "elasticsearch_cluster_health" WHERE ("portfolio" = \'reliability_engineering\' AND "env" = \'production\') AND time >= now() - 15m GROUP BY time(10s) fill(null)'
    expect(Telemetry::IFQL::Parser.new(query).measurement).to eq 'elasticsearch_cluster_health'
  end

  it 'can support grafana measurement queries' do
    query = 'SHOW MEASUREMENTS WITH MEASUREMENT =~ /brea/ LIMIT 100'
    expect(Telemetry::IFQL::Parser.new(query).measurement).to eq 'brea'
  end

  it 'can find the time frame' do
    query = 'SELECT mean("relocating_shards") AS "Relocating", mean("unassigned_shards") AS "Unassigned", mean("active_shards") AS "Active", mean("initializing_shards") AS "Initializing" FROM "elasticsearch_cluster_health" WHERE ("portfolio" = \'reliability_engineering\' AND "env" = \'production\') AND $timeFilter GROUP BY time(10s) fill(null)'
    expect(Telemetry::IFQL::Parser.new(query).group_by_time).to eq 10

    query = 'SELECT mean("relocating_shards") AS "Relocating", mean("unassigned_shards") AS "Unassigned", mean("active_shards") AS "Active", mean("initializing_shards") AS "Initializing" FROM "elasticsearch_cluster_health" WHERE ("portfolio" = \'reliability_engineering\' AND "env" = \'production\') AND $timeFilter GROUP BY time(1h) fill(null)'
    expect(Telemetry::IFQL::Parser.new(query).group_by_time).to eq 3600

    query = 'SELECT mean("relocating_shards") AS "Relocating", mean("unassigned_shards") AS "Unassigned", mean("active_shards") AS "Active", mean("initializing_shards") AS "Initializing" FROM "elasticsearch_cluster_health" WHERE ("portfolio" = \'reliability_engineering\' AND "env" = \'production\') AND $timeFilter GROUP BY time(30m) fill(null)'
    expect(Telemetry::IFQL::Parser.new(query).group_by_time).to eq 1800

    query = 'SELECT mean("relocating_shards") AS "Relocating", mean("unassigned_shards") AS "Unassigned", mean("active_shards") AS "Active", mean("initializing_shards") AS "Initializing" FROM "elasticsearch_cluster_health" WHERE ("portfolio" = \'reliability_engineering\' AND "env" = \'production\') AND $timeFilter GROUP BY time(10h) fill(null)'
    expect(Telemetry::IFQL::Parser.new(query).group_by_time).to eq 36_000

    query = 'SELECT mean("relocating_shards") AS "Relocating", mean("unassigned_shards") AS "Unassigned", mean("active_shards") AS "Active", mean("initializing_shards") AS "Initializing" FROM "elasticsearch_cluster_health" WHERE ("portfolio" = \'reliability_engineering\' AND "env" = \'production\') AND $timeFilter GROUP BY time(10h5m) fill(null)'
    expect(Telemetry::IFQL::Parser.new(query).group_by_time).to eq 36_300

    query = 'SELECT mean("relocating_shards") AS "Relocating", mean("unassigned_shards") AS "Unassigned", mean("active_shards") AS "Active", mean("initializing_shards") AS "Initializing" FROM "elasticsearch_cluster_health" WHERE ("portfolio" = \'reliability_engineering\' AND "env" = \'production\') AND $timeFilter GROUP BY time(1m1s) fill(null)'
    expect(Telemetry::IFQL::Parser.new(query).group_by_time).to eq 61
  end

  it 'can handle condition exceptions' do
    query = 'SELECT mean("test") AS "test" WHERE!@#@!$% (#&@%*& AND ##)'
    expect { Telemetry::IFQL::Parser.new(query).conditions }.not_to raise_exception

    expect { Telemetry::IFQL::Parser.new(query).limit? }.not_to raise_exception
  end

  it 'can handle multi queries' do
    query = 'SHOW TAG VALUES FROM cpu WITH KEY = "dc" WHERE test = "foo" AND foo = "bar"; SELECT non_negative_difference(max(read_time)) FROM telegraf.autogen.diskio WHERE time >= now() - 1h GROUP BY time(1m), host'
    expect(described_class.new(query).query_type).to eq :multi_data
  end
end
