# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to create a new property for an account
      # Note: Not sure if it should update info from the account object? search account > get property > update
      class UpdateProperty
        def self.call(requester:, property_data:, updated_data:)
          policy = Policies::Property.new(requester:, property_owner_id: property_data.account[:id],
                                          property_owner_executor_id: property_data.account.executor_id)

          unless policy.can_update?
            raise Exceptions::ForbiddenError,
                  'You are not allowed to updated property selected.'
          end

          raise Exceptions::BadRequestError updated_data.keys.to_s unless property_data.update(updated_data)
        end
      end
    end
  end
end
