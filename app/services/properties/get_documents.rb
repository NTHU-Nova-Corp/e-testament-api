# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to create a new property for an account
      class GetDocuments
        def self.call(property_id:)
          documents = Property.first(id: property_id).documents
          raise Exceptions::NotFoundError, 'Document not found' if documents.nil?

          documents.to_json
        end
      end
    end
  end
end
