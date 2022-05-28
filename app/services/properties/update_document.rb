# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to create a new property for an account
      class UpdateDocument
        def self.call(updated_data:, property_id:, document_id:)
          property = Property.where(id: property_id).first
          raise Exceptions::NotFoundError if property.nil?

          document = Document.first(id: document_id, property_id:)
          raise Exceptions::NotFoundError if document.nil?

          raise(updated_data.keys.to_s) unless document.update(updated_data)
        end
      end
    end
  end
end
