# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to create a new property for an account
      class GetDocument
        def self.call(property_id:, document_id:)
          property = Property.first(id: property_id)
          raise Exceptions::NotFoundError if property.nil?

          document = Document.first(id: document_id, property_id:)
          raise Exceptions::NotFoundError if document.nil?

          document.to_json
        end
      end
    end
  end
end
