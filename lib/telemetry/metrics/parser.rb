require 'telemetry/metrics/parser/version'
require 'telemetry/metrics/parser/line_protocol'

module Telemetry
  module Metrics
    module Parser
      def line_protocol(line)
        Telemetry::Metrics::Parser::LineProtocol.parse(line)
      end
      module_function :line_protocol
    end
  end
end
