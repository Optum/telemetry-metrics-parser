require 'shellwords'
require 'telemetry/number_helper'

module Telemetry
  module Metrics
    module Parser
      module LineProtocol
        extend Telemetry::NumberHelper

        def parse(line, use_shellwords: true)
          if use_shellwords
            raw_tags, raw_fields, timestamp = Shellwords.split(line.strip)
          else
            raw_tags, raw_fields, timestamp = line.strip.split
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
          return results if raw_string.nil?

          raw_string.split(',').each do |string|
            next unless string.include? '='

            k, v = string.split('=')
            results[k.to_sym] = convert_to_number(v)
          end

          results
        end
        module_function :split_string_to_hash

        def to_line_protocol(measurement:, fields:, tags: {}, timestamp: DateTime.now.strftime('%Q'))
          "#{measurement},#{hash_to_line(tags)} #{hash_to_line(fields)} #{timestamp}"
        end
        module_function :to_line_protocol

        def hash_to_line(hash)
          hash.map { |k, v| "#{k}=#{v}" }.join(',').strip.delete_suffix(',')
        end
        module_function :hash_to_line

        def line_is_recent?(timestamp, max_age_sec: 86_400)
          return false unless timestamp.is_a?(Integer)
          return false unless max_age_sec.is_a?(Integer)

          current_epoch_ns = DateTime.now.strftime('%s%9N').to_i
          timestamp >= current_epoch_ns - (max_age_sec * 1000 * 1000 * 1000 * 3)
        end
        module_function :line_is_recent?

        def field_is_number?(value)
          return false if value.nil?
          return true if value.is_a?(Integer)
          return true if value.is_a?(Float)

          %(f i).include?(value[-1])
        end
        module_function :field_is_number?

        def tag_is_valid?(key, value)
          return false if key.nil? || value.nil?
          return false unless value.chars.detect { |ch| !valid_tag_chars.include?(ch) }.nil?
          return false unless key.to_s.chars.detect { |ch| !valid_tag_chars.include?(ch) }.nil?

          true
        end
        module_function :tag_is_valid?

        def node_group_tag?(tags)
          tags[:influxdb_node_group].is_a?(String)
        end
        module_function :node_group_tag?

        def database_tag?(tags)
          tags[:influxdb_database].is_a?(String)
        end
        module_function :database_tag?

        def measurement_valid?(measurement)
          return false unless measurement.is_a?(String)

          measurement.chars.detect { |ch| !valid_measurement_chars.include?(ch) }.nil?
        end
        module_function :measurement_valid?

        def valid_measurement_chars
          @valid_measurement_chars ||= ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a + %w[_ - .]
        end
        module_function :valid_measurement_chars

        def valid_tag_chars
          @valid_tag_chars ||= ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a + %w[_ - .]
        end
        module_function :valid_tag_chars

        def line_is_valid?(line) # rubocop:disable Metrics/AbcSize
          line = parse(line) if line.is_a?(String)
          return "line is too old, #{line}" unless line_is_recent?(line[:timestamp])
          return "line is missing influxdb_database, #{line}" unless node_group_tag? line[:tags]
          return "line is missing influxdb_node_group, #{line}" unless database_tag? line[:tags]
          return "measurement name #{line[:measurement]} is not valid" unless measurement_valid?(line[:measurement])

          line[:fields].each do |field, value|
            next if field_is_number?(value)

            return "field values must be an Integer or String, #{field} :#{value} #{value.class}"
          end

          line[:tags].each do |tag, value|
            next if tag_is_valid?(tag, value)

            return "tags must be a-z0-9_-. but was given #{tag}: #{value}"
          end

          true
        end
        module_function :line_is_valid?
      end
    end
  end
end
