# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to create a new property for an account
      class DeleteDocument
        def self.call(property_id:, document_id:)
          property = Property.first(id: property_id)
          raise Exceptions::NotFoundError if property.nil?

          current_document = Document.first(id: document_id, property_id:)
          raise Exceptions::NotFoundError if current_document.nil?
          raise('Could not delete document associated with property') unless current_document.delete
        end
      end
    end
  end
end
