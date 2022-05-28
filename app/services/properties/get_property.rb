# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to get a specific property
      class GetProperty
        def self.call(property_id:)
          property = Property.first(id: property_id)
          raise Exceptions::NotFoundError if property.nil?

          property.to_json
        end
      end
    end
  end
end
