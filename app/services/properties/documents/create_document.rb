# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to create a new property for an account
      class CreateDocument
        def self.call(property_id:, new_data:)
          property = Property.find(id: property_id)
          new_document = property.add_document(new_data)
          raise Exceptions::BadRequestError, 'Could not save document' unless new_document.save

          new_document
        end
      end
    end
  end
end
