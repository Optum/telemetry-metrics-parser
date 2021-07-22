require 'telemetry/metrics/parser/version'
require 'telemetry/metrics/parser/line_protocol'

module Telemetry
  module Metrics
    module Parser
      def from_line_protocol(line, **opts)
        Telemetry::Metrics::Parser::LineProtocol.parse(line, **opts)
      end
      module_function :from_line_protocol

      def to_line_protocol(**opts)
        Telemetry::Metrics::Parser::LineProtocol.to_line_protocol(**opts)
      end
      module_function :to_line_protocol
    end
  end
end
