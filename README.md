# Telemetry::Metrics::Parser
A ruby gem designed to parse and process telemetry style metrics


## InfluxDB Line Protocol
```
# weather,location=us-midwest temperature=82 1465839830100400200
#   |    -------------------- --------------  |
#   |             |             |             |
#   |             |             |             |
# +-----------+--------+-+---------+-+---------+
# |measurement|,tag_set| |field_set| |timestamp|
# +-----------+--------+-+---------+-+---------+
```

Example
```ruby
require 'telemetry/metrics/parser'
results = Telemetry::Metrics::Parser.line_protocol('weather,location=us-midwest temperature=82 1465839830100400200')

results[:measurement] # => weather
results[:tags] # => { location: 'us-midwest' }
results[:fields] # => { temperature: 82 }
results[:timestamp] # => 1465839830100400200
```

#### Validations
```ruby
Telemetry::Metrics::Parser::LineProtocol.line_is_valid?('weather,location=us-midwest temperature=82 1465839830100400200') # true
Telemetry::Metrics::Parser::LineProtocol.line_is_valid?('weather,location=us-midwest temperature=this_field_is_a_string 1465839830100400200') # false but returned as a string error
```

Authors
----------

* [Matthew Iverson](https://github.com/Esity) - current maintainer