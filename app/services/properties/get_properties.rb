# frozen_string_literal: true

module ETestament
  module Services
    module Properties
      # Service object to get the properties related with an an account
      class GetProperties
        def self.call(requester:, account_id:)
          account = Account.first(id: account_id)

          policy = Policies::Property.new(requester:, property_owner_id: account_id,
                                          property_owner_executor_id: account.executor_id)

          unless policy.can_view?
            raise Exceptions::ForbiddenError,
                  'You are not allowed to view property requested.'
          end

          output = { data: account.properties }
          JSON.pretty_generate(output)
        end
      end
    end
  end
end
