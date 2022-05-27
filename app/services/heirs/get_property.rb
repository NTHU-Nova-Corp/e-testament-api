# frozen_string_literal: true

module ETestament
  module Services
    module Heirs
      # Service object to get the heirs related with an an account
      class GetProperty
        def self.call(heir_id:, property_id:)
          output = { data: PropertyHeir.first(heir_id:, property_id:) }
          JSON.pretty_generate(output)
        end
      end
    end
  end
end
