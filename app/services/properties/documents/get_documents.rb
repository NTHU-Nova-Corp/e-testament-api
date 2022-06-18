# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to create a new property for an account
      class GetDocuments
        def self.call(requester:, property_data:)
          policy = Policies::Document.new(requester:,
                                          testament_status: property_data.account[:testament_status],
                                          property_owner_id: property_data.account[:id],
                                          property_owner_executor_id: property_data.account[:executor_id])

          raise Exceptions::ForbiddenError, 'You are not allowed view the document requested.' unless policy.can_view?

          documents = property_data.documents
          raise Exceptions::NotFoundError, 'Documents not found' if documents.nil?

          documents
        end
      end
    end
  end
end
