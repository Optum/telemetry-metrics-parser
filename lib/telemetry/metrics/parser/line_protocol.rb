require 'shellwords'
require 'telemetry/metrics/parser/number_helper'

module Telemetry
  module Metrics
    module Parser
      module LineProtocol
        extend Telemetry::Metrics::Parser::NumberHelper

        def parse(line, use_shellwords: false)
          if use_shellwords
            raw_tags, raw_fields, timestamp = Shellwords.split(line)
          else
            raw_tags, raw_fields, timestamp = line.split
          end

          {
            measurement: get_measurement(line),
            tags: split_string_to_hash(raw_tags),
            fields: split_string_to_hash(raw_fields),
            timestamp: convert_to_number(timestamp)
          }
        end
        module_function :parse

        def get_measurement(line)
          measurement = line.split(',').first
          return nil if measurement.include? '='

          measurement
        end
        module_function :get_measurement

        def split_string_to_hash(raw_string)
          results = {}
          raw_string.split(',').each do |string|
            next unless string.include? '='

            k, v = string.split('=')
            results[k.to_sym] = convert_to_number(v)
          end

          results
        end
        module_function :split_string_to_hash
      end
    end
  end
end
