# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to create a new property for an account
      class UpdateDocument
        def self.call(requester:, property_data:, document_data:, updated_data:)
          policy = Policies::Document.new(requester:, property_owner_id: property_data.account[:id])
          unless policy.can_edit?
            raise Exceptions::ForbiddenError,
                  'You are not allowed to update the document selected.'
          end

          raise Exceptions::BadRequestError updated_data.keys.to_s unless document_data.update(updated_data)
        end
      end
    end
  end
end
