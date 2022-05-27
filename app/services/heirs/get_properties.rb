# frozen_string_literal: true

module ETestament
  # Service object to create a new property for an account
  module Services
    module Heirs
      # Create heir for account
      class GetProperties
        def self.call(heir_id:)
          property_heirs = PropertyHeir.where(heir_id:).all
          properties = property_heirs.map(&:property)

          raise Exceptions::NotFoundError if properties.nil?

          properties.to_json
        end
      end
    end
  end
end
