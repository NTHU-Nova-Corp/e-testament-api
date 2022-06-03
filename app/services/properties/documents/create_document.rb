# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to create a new property for an account
      class CreateDocument
        def self.call(requester:, property_data:, new_data:)
          policy = Policies::Document.new(requester:, property_owner_id: property_data.account[:id])
          unless policy.can_create?
            raise Exceptions::ForbiddenError, 'You are not allowed to create documents for the property selected.'
          end

          new_document = property_data.add_document(new_data)
          raise Exceptions::BadRequestError, 'Could not save document' unless new_document.save

          new_document
        end
      end
    end
  end
end
