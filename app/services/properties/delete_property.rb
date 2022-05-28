# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to create a new property for an account
      class DeleteProperty
        def self.call(property_id:)
          raise('Could not delete property') unless Property.where(id: property_id).delete
        end
      end
    end
  end
end
