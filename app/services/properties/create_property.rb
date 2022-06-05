# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to create a new property for an account
      class CreateProperty
        def self.call(requester:, account_id:, new_data:)
          account = Account.first(id: account_id)

          policy = Policies::Property.new(requester:, property_owner_id: account_id,
                                          property_owner_executor_id: account.executor_id)

          unless policy.can_create?
            raise Exceptions::ForbiddenError,
                  'You are not allowed to create properties for the account requested'
          end

          raise Exceptions::BadRequestError, 'Could not save property' unless account.add_property(new_data).save

          new_property
        end
      end
    end
  end
end
