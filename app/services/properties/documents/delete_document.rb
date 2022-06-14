# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to create a new property for an account
      class DeleteDocument
        def self.call(requester:, property_data:, document_data:)
          policy = Policies::Document.new(requester:,
                                          testament_status: property_data.account[:testament_status],
                                          property_owner_id: property_data.account[:id],
                                          property_owner_executor_id: property_data.account[:executor_account_id])
          unless policy.can_delete?
            raise Exceptions::ForbiddenError, 'You are not allowed to delete the document selected.'
          end

          current_document = Document.first(id: document_data[:id], property_id: property_data[:id])
          raise Exceptions::NotFoundError if current_document.nil?
          raise('Could not delete document associated with property') unless current_document.delete
        end
      end
    end
  end
end
