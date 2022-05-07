# frozen_string_literal: true

module ETestament
  # Service object to create a new property for an account
  class CreateDocumentForProperty
    def self.call(property_id:, document:)
      Property.find(id: property_id)
              .add_document(document)
    end
  end
end
