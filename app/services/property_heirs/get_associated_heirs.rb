# frozen_string_literal: true

module ETestament
  module Services
    module PropertyHeirs
      # Service object to create a new property for an account
      class GetAssociatedHeirs
        def self.call(property_id:)
          property_heirs = PropertyHeir.where(property_id:).all
          raise Exceptions::NotFoundError if property_heirs.nil?

          heirs = property_heirs.map { |property| Heir.first(id: property[:heir_id]) }
          raise Exceptions::NotFoundError if heirs.nil?

          heirs.to_json
        end
      end
    end
  end
end
