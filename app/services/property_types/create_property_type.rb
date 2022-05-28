# frozen_string_literal: true

module ETestament
  module Services
    module PropertyType
      # Service object to create a new property for an account
      class CreatePropertyType
        def self.call(new_data:)
          new_property_type = ETestament::PropertyType.new(new_data)
          raise Exceptions::BadRequestError, 'Could not save property type' unless new_property_type.save

          new_property_type
        end
      end
    end
  end
end
