# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to create a new property for an account
      class GetDocument
        def self.call(requester:, property_data:, document_data:)
          policy = Policies::Document.new(requester:, property_owner_id: property_data.account[:id])
          raise Exceptions::ForbiddenError, 'You are not allowed view the document requested.' unless policy.can_view?

          document_data.to_json
        end
      end
    end
  end
end
