module Telemetry
  module IFQL
    module Formats
      def measurement_error(message, show_error_message: true, status: 500, **)
        response = MEASUREMENT.dup
        response[:result] = {
          error: message,
          show_error_message: show_error_message,
          status: status
        }
        response
      end
      module_function :measurement_error

      MEASUREMENT = {
        results: [
          {
            statement_id: 0,
            series: [
              {
                name: 'measurements',
                columns: ['name'],
                values: []
              }
            ]
          }
        ]
      }.freeze

      FIELD_KEYS = {
        results: [
          {
            statement_id: 0,
            series: [
              {
                name: nil,
                columns: %w[fieldKey fieldType],
                values: []
              }
            ]
          }
        ]
      }.freeze

      DATABASE = {
        results: [
          {
            statement_id: 0,
            series: [
              {
                name: 'databases',
                columns: ['name'],
                values: [['telegraf']]
              }
            ]
          }
        ]
      }.freeze

      RETENTION_POLCIES = {
        results: [
          {
            statement_id: 0,
            series: [
              {
                columns: %w[
                  name
                  duration
                  shardGroupDuration
                  replicaN
                  default
                ],
                values: [['autogen', '9600h0m0s', '24h0m0s', 1, true]]
              }
            ]
          }
        ]
      }.freeze

      TAG_VALUES = {
        results: [
          {
            statement_id: 0,
            series: [
              {
                name: 'conflux',
                columns: %w[
                  key
                  value
                ],
                values: []
              }
            ]
          }
        ]
      }.freeze
    end
  end
end
