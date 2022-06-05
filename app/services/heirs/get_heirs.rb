# frozen_string_literal: true

module ETestament
  module Services
    module Heirs
      # Service object to get the heirs related with an an account
      class GetHeirs
        def self.call(requester:, account_id:)
          account = Account.first(id: account_id)

          policy = Policies::Heir.new(requester:, heir_owner_id: account_id,
                                      heir_owner_executor_id: account.executor_id)

          unless policy.can_view?
            raise Exceptions::ForbiddenError,
                  'You are not allowed to view heirs requested.'
          end

          account.heirs
        end
      end
    end
  end
end
