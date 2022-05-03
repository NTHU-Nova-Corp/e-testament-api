# frozen_string_literal: true

module ETestament
  # Service object to create a new property for an account
  class CreateDocumentForProperty
    def self.call(id:, document:)
      Property.find(id:)
              .add_document(document)
    end
  end
end
