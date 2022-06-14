# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to create a new property for an account
      class UpdateDocument
        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def self.call(requester:, property_data:, document_data:, updated_data:)
          policy = Policies::Document.new(requester:,
                                          testament_status: property_data.account[:testament_status],
                                          property_owner_id: property_data.account[:id],
                                          property_owner_executor_id: property_data.account[:executor_account_id])

          unless policy.can_edit?
            raise Exceptions::ForbiddenError,
                  'You are not allowed to update the document selected.'
          end

          unless property_data.documents.count do |document|
                   document.file_name == updated_data['file_name'] && document.id != document_data.id
                 end.zero?
            raise Exceptions::BadRequestError,
                  'There is already a document with the same name'
          end

          raise Exceptions::BadRequestError updated_data.keys.to_s unless document_data.update(updated_data)
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
      end
    end
  end
end
