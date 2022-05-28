# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to create a new property for an account
      # Note: Not sure if it should update info from the account object? search account > get property > update
      class UpdateProperty
        def self.call(property_id:, updated_data:)
          property = Property.first(id: property_id)
          raise Exceptions::NotFoundError if property.nil?

          raise(updated_data.keys.to_s) unless property.update(updated_data)
        end
      end
    end
  end
end
