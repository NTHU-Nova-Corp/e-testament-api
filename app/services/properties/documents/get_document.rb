# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to create a new property for an account
      class GetDocument
        def self.call(requester:, property_data:, document_data:)
          policy = Policies::Document.new(requester:,
                                          testament_status: property_data.account[:testament_status],
                                          property_owner_id: property_data.account[:id],
                                          property_owner_executor_id: property_data.account[:executor_account_id])

          raise Exceptions::ForbiddenError, 'You are not allowed view the document requested.' unless policy.can_view?

          document_data
        end
      end
    end
  end
end
