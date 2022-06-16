# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to create a new property for an account
      class CreateDocument
        # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
        def self.call(requester:, property_data:, new_data:)
          policy = Policies::Document.new(requester:,
                                          testament_status: property_data.account[:testament_status],
                                          property_owner_id: property_data.account[:id],
                                          property_owner_executor_id: property_data.account[:executor_id])
          unless policy.can_create?
            raise Exceptions::ForbiddenError, 'You are not allowed to create documents for the property selected.'
          end

          unless property_data.documents.count { |document| document.file_name == new_data['file_name'] }.zero?
            raise Exceptions::BadRequestError,
                  'There is already a document with the same name'
          end

          new_document = property_data.add_document(new_data)
          raise Exceptions::BadRequestError, 'Could not save document' unless new_document.save

          new_document
        end
        # rubocop: enable Metrics/MethodLength, Metrics/AbcSize
      end
    end
  end
end
