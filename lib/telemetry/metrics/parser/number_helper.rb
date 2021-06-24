module Telemetry
  module Metrics
    module Parser
      module NumberHelper
        def number?(str)
          [str.to_f.to_s, str.to_i.to_s].include?(str)
        end
        module_function :number?

        def float?(string)
          string == string.to_f.to_s
        end
        module_function :float?

        def integer?(string)
          string == string.to_i.to_s
        end
        module_function :integer?

        def convert_to_number(string)
          if integer?(string)
            string.to_i
          elsif float?(string)
            string.to_f
          else
            string
          end
        end
        module_function :convert_to_number
      end
    end
  end
end
