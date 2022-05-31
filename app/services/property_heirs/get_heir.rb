# frozen_string_literal: true

module ETestament
  module Services
    module PropertyHeirs
      # Service object to get a specific property
      class GetPropertyHeir
        def self.call(property_id:, heir_id:)
          property = Property.where(id: property_id)
          raise Exceptions::NotFoundError if property.nil?

          heir = Heir.first(id: heir_id, property_id:)
          raise Exceptions::NotFoundError if heir.nil?

          heir.to_json
        end
      end
    end
  end
end
